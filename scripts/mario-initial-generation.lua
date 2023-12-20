local tools = require("tools")

-- set max speed on emulator
emu.speedmode("maximum")

local farthestPosition = 0
local bestSolutionYet = nil
local finalSolution = nil
local motifs = require("motifs")
local motifKeys = {"right", "rightA", "rightB", "rightAB", "left", "leftA", "leftB", "leftAB"}
local frameDurations = {10, 15, 20, 25, 30}
local n = 5 -- Starting length of the solution
local goalXPosition = 89 + (12 * 256) -- win position


local initialSave = savestate.create(5)

-- Function that given a motif, executes it for a given number of frames
function executeMotif(motif, frames)
    for i = 1, frames do
        joypad.set(1, motif)
        emu.frameadvance()
    end
end

-- Function to check if the fail state is achieved by the player
function checkIfFailState()
    local isFallIntoPit = false
    local playerState = memory.readbyte(0x000E)
    local playingDeathMusic = memory.readbyte(0x0712)
    if playerState == 6 or playerState == 11 or playingDeathMusic == 1 then -- 6 game over, 11 dead via enemy
        if (playingDeathMusic == 1) then -- playingDeathMusic 1 is when falling into a hole and dying
            isFallIntoPit = true
        end
        return true, isFallIntoPit
    end
    return false
end

-- Function to check if the win state is achieved by the player
function checkIfWinState(goalXPosition, currentXPosition)
    if currentXPosition >= goalXPosition then
        return true
    end
    return false
end

-- Function to create a solution with the first motif+duration and length n
function createSolution(length)
    local solution = {}
    for i = 1, length do
        table.insert(solution, {
            motif = motifKeys[1],
            duration = frameDurations[1]
        })
    end
    return solution
end

-- Function to execute a solution
function executeSolution(solution, goalXPosition)
    local lastPosition = tools.getCurrentMarioPosition()
    for i, motifData in ipairs(solution) do

        executeMotif(motifs[motifData.motif], motifData.duration) -- Execute the motif with the specified duration
        local currentPositionX, currentPositionY = tools.getCurrentMarioPosition()

        if currentPositionX > farthestPosition then
            farthestPosition = currentPositionX
            bestSolutionYet = solution
            emu.print("Goal position: " .. goalXPosition .. ", Farthest position: " .. farthestPosition)
            emu.print("Best solution yet: " .. tools.solutionToString(bestSolutionYet))
        end

        local failState, isFallIntoPit = checkIfFailState()
        if failState then
            failingMotifIndex = i - 1
            if (isFallIntoPit) then
                failingMotifIndex = i - 1 -- Return previous motif if Mario fell into a pit
            elseif (currentPositionX == lastPosition) then
                failingMotifIndex = i - 1 -- Return the previous motif if Mario is stuck dying with an enemy
            end
            return "fail", failingMotifIndex -- Return fail status and the index of the failing motif
        elseif lastPosition == currentPositionX then
            return "stuck", i -- Return stuck status and the index of the motif where Mario gets stuck
        elseif checkIfWinState(goalXPosition, currentPositionX) then
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
local solution = createSolution(n) -- initialize solution with length n
repeat
    local failIndex = nil
    status, failIndex = executeSolution(solution, goalXPosition)

    if status == "fail" or status == "stuck" then
        savestate.load(initialSave) -- Load the initial save state to place Mario back at the start

        if failIndex then
            local currentMotifData = solution[failIndex]
            local currentMotifIndex = findInTable(motifKeys, currentMotifData.motif)
            local currentFrameDurationIndex = findInTable(frameDurations, currentMotifData.duration)

            -- Cycle through motifs and frame durations before increasing length of solution
            if currentFrameDurationIndex < #frameDurations then
                currentMotifData.duration = frameDurations[currentFrameDurationIndex + 1]
            else
                currentMotifData.duration = frameDurations[1]
                currentMotifData.motif = motifKeys[(currentMotifIndex % #motifKeys) + 1]
            end
        else
            -- Handle the case when failIndex is nil, increase length of solution
            table.insert(solution, {
                motif = motifKeys[1],
                duration = frameDurations[1]
            })
            n = #solution
        end
    elseif status == "win" then
        emu.print("Win state achieved with current solution!")
        tools.appendSolutionToFile(solution)
        finalSolution = solution
        break
    end


until status == "win"

-- At this point, finalSolution should be feasible
emu.print("Final feasible solution found: " .. tools.solutionToString(finalSolution))
emu.pause()
