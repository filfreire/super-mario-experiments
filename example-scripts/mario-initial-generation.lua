local tools = require("tools")

emu.print("Start!")

-- set max speed on emulator
emu.speedmode("maximum")


local farthestPosition = 0



local motifs = require("motifs")
local motifKeys = {"right", "rightA", "rightB", "rightAB", "left", "leftA", "leftB", "leftAB"}
local frameDurations = {10, 20, 30}


local initialSave = savestate.create(5)
print(os.getenv("foo"))

-- function that given a motif, executes it for a given number of frames
function executeMotif(motif, frames)
    for i = 1, frames do
        joypad.set(1, motif)
        emu.frameadvance()
    end
end

function checkIfFailState()
    local isFallIntoPit = false
    local playerState = memory.readbyte(0x000E)
    -- 8 normal
    -- 6 game over
    -- 11 dead via enemy

    local playingDeathMusic = memory.readbyte(0x0712)
    -- playingDeathMusic 1 is when falling into a hole and dying

    if playerState == 6 or playerState == 11 or playingDeathMusic == 1 then
-- emu.print("Fail state detected!")

        if (playingDeathMusic == 1) then
            isFallIntoPit = true
        end
        return true, isFallIntoPit
    end
    return false
end


function checkIfWinState(goalXPosition, currentXPosition)
    if currentXPosition >= goalXPosition then
-- emu.print("Win state detected!")

        return true
    end
    return false
end

-- Function to create a solution with the top motif and length n
function createSolution(length)
    local solution = {}
    for i = 1, length do
        table.insert(solution, {
            motif = motifKeys[1],
            duration = frameDurations[1]
        }) -- Inserting the key of the top-ranked motif and the first frame duration

    end
    return solution
end

-- Function to execute a solution
function executeSolution(solution, goalXPosition)
    local lastPosition = tools.getCurrentMarioPosition()
-- emu.print("Executing solution: " .. tools.solutionToString(solution))

    for i, motifData in ipairs(solution) do

        executeMotif(motifs[motifData.motif], motifData.duration) -- Execute the motif with the specified duration
        local currentPositionX, currentPositionY = tools.getCurrentMarioPosition()

        if currentPositionX > farthestPosition then
            farthestPosition = currentPositionX
            emu.print("Goal position: " .. goalXPosition)
            emu.print("Farthest position: " .. farthestPosition)
        end


        local failState, isFallIntoPit = checkIfFailState()

        if failState then
            failingMotifIndex = i - 1
            if (isFallIntoPit) then
                failingMotifIndex = i - 1 -- Return previous motif if Mario fell into a pit
            elseif (currentPositionX == lastPosition) then
                failingMotifIndex = i - 1 -- Return the previous motif if Mario died via an enemy and is stuck
            end
            return "fail", failingMotifIndex -- Return fail status and the index of the failing motif
        elseif lastPosition == currentPositionX then
            return "stuck", i -- Return stuck status and the index of the motif where Mario got stuck
        elseif checkIfWinState(goalXPosition, currentPositionX) then
            emu.pause()
            return "win", nil -- Return win status
        end
        lastPosition = currentPositionX
    end
    return "fail", nil -- Return fail status and nil as the index of the failing motif

end

-- Function to find the index of a key in a tabl
function findInTable(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil -- or any default value you'd like to return if the value isn't found
end


-- Main algorithm
local n = 5 -- Starting length of the solution
local goalXPosition = 89 + (12 * 256) -- win position

local solution = createSolution(n)
local failIndex


emu.print("Initial solution: " .. tools.solutionToString(solution))

repeat
    status, failIndex = executeSolution(solution, goalXPosition)

    if status == "fail" or status == "stuck" then
        savestate.load(initialSave)

        if failIndex then
            local currentMotifData = solution[failIndex]
            local currentMotifIndex = findInTable(motifKeys, currentMotifData.motif)
            local currentFrameDurationIndex = findInTable(frameDurations, currentMotifData.duration)

            -- Cycle through motifs and frame durations
            if currentFrameDurationIndex < #frameDurations then
                currentMotifData.duration = frameDurations[currentFrameDurationIndex + 1]
            else
                currentMotifData.duration = frameDurations[1]
                currentMotifData.motif = motifKeys[(currentMotifIndex % #motifKeys) + 1]
            end
        else
            -- Handle the case when failIndex is nil
            table.insert(solution, {
                motif = motifKeys[1],
                duration = frameDurations[1]
            })
            n = #solution -- Update the length of the solution
        end
    elseif status == "win" then
        emu.print("Win state achieved with current solution!")
        tools.appendSolutionToFile(solution)
        break -- Exit the loop if win state is achieved
    end


until status == "win"


-- At this point, solution should be feasible
