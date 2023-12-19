emu.print("Start!")

-- set max speed on emulator
emu.speedmode("maximum")


local motifs = require("motifs")
local motifKeys = {"right", "rightA", "rightB", "rightAB", "left", "leftA", "leftB", "leftAB"}

local initialSave = savestate.create(5)
print(os.getenv("foo"))


-- function that prints the current position of Mario
function debugMarioPosition()
    local marioVerticalPosition = memory.readbyte(0x00CE)
    local marioVerticalMultiplier = memory.readbyte(0x00B5)

    local marioHorinzontalPosition = memory.readbyte(0x0086)
    local marioHorinzontalMultiplier = memory.readbyte(0x006D)

    -- local notsurePosX = memory.readbyte(0x03AD)
    -- local notsurePosX2 = memory.readbyte(0x071D)
    -- emu.print("Not sure: " .. notsurePosX .. ", " .. notsurePosX2)

    emu.print("Mario position total: " .. (marioHorinzontalPosition + (256 * marioHorinzontalMultiplier)) .. ", " ..
                  (marioVerticalPosition + (256 * marioVerticalMultiplier)))
    emu.print("Player state/playing death music: " .. playerState .. ", " .. playingDeathMusic)
end

-- function that given a motif, executes it for a given number of frames
function executeMotif(motif, frames)
    for i = 1, frames do
        joypad.set(1, motif)
        emu.frameadvance()
    end
    -- emu.print("Executed motif: " .. tostring(motif) .. " for " .. frames .. " frames")
end

-- append solution to a file
function appendSolutionToFile(solution)
    local lfs = require("lfs")
    local currentDirectory = lfs.currentdir()

    local fileName = "..\\data\\solutions.txt"
    local fullPath = currentDirectory .. "\\" .. fileName
    print("The file path is: " .. fullPath)

    local file = io.open(fileName, "a")

    if file then
        file:write(table.concat(solution, ", ") .. "\n")
        file:close()
    else
        print("Unable to open or create the file.")
    end
end

function checkIfFailState()
    local playerState = memory.readbyte(0x000E)
    -- 8 normal
    -- 6 game over
    -- 11 dead via enemy
    -- playingDeathMusic 1 is when falling into a hole and dying

    local playingDeathMusic = memory.readbyte(0x0712)
    -- 0 not playing
    -- 1 playing death music, so player lost a life
    if playerState == 6 or playerState == 11 or playingDeathMusic == 1 then
        emu.print("Fail state detected!")
        return true
    end
    return false
end


function getCurrentMarioPosition()
    local marioVerticalPosition = memory.readbyte(0x00CE)
    local marioVerticalMultiplier = memory.readbyte(0x00B5)

    local marioHorinzontalPosition = memory.readbyte(0x0086)
    local marioHorinzontalMultiplier = memory.readbyte(0x006D)

    return marioHorinzontalPosition + (256 * marioHorinzontalMultiplier),
        marioVerticalPosition + (256 * marioVerticalMultiplier)
end


function checkIfWinState(goalXPosition)
    local currentPosX, currentPosY = getCurrentMarioPosition()
    if currentPosX >= goalXPosition then
        emu.print("Win state detected!")
        return true
    end
    return false
end



-- Function to create a solution with the top motif and length n
function createSolution(length)
    local solution = {}
    for i = 1, length do
        table.insert(solution, motifKeys[1]) -- Inserting the key of the top-ranked motif
    end
    return solution
end

-- Function to execute a solution
function executeSolution(solution, goalXPosition, currentPosition)
    local lastPosition = getCurrentMarioPosition()
    emu.print("Executing solution: " .. table.concat(solution, ", "))
    for i, motifKey in ipairs(solution) do
        executeMotif(motifs[motifKey], 10) -- Execute the motif
        local currentPosition = getCurrentMarioPosition()
        -- emu.print("Current position: " .. currentPosition)

        if checkIfFailState() then
            return "fail", i -- Return fail status and the index of the failing motif
        elseif lastPosition == currentPosition then
            return "stuck", i -- Return fail status and the index of the failing motif
        elseif checkIfWinState(goalXPosition) then
            return "win", nil -- Return win status
        end
        lastPosition = currentPosition
    end
    return "fail", nil -- Return fail status and nil as the index of the failing motif
end

-- Function to find the index of a key in the motifKeys table
function findMotifIndex(key)
    for i, v in ipairs(motifKeys) do
        if v == key then
            return i
        end
    end
    return nil
end

-- Main algorithm
local n = 5 -- Starting length of the solution
local goalXPosition = 89 + (12 * 256) -- win position

local solution = createSolution(n)
local failIndex

emu.print("Initial solution: " .. table.concat(solution, ", "))

repeat
    -- load initialSave

    status, failIndex = executeSolution(solution, goalXPosition)

    if status == "fail" then
        savestate.load(initialSave)
        -- Increase the length of the solution if the end of the motifKeys list is reached
        if failIndex == nil then
            emu.print("FAIL!")
            table.insert(solution, motifKeys[1])
            n = #solution -- Update the length of the solution
        else
            -- Find the index of the failing motif in the motifKeys list
            local currentMotifIndex = findMotifIndex(solution[failIndex])

            -- Replace failing motif with the next in the hierarchy
            local nextMotifIndex = (currentMotifIndex % #motifKeys) + 1
            solution[failIndex] = motifKeys[nextMotifIndex]

            -- Increase the length of the solution if the end of the motifKeys list is reached
            if nextMotifIndex == 1 then
                n = n + 1
                solution = createSolution(n)
            end
        end
    elseif status == "stuck" then
        emu.print("STUCK!")

        if failIndex == nil then
            table.insert(solution, motifKeys[1])
            n = #solution -- Update the length of the solution
        else
            -- Find the index of the failing motif in the motifKeys list
            local currentMotifIndex = findMotifIndex(solution[failIndex])

            -- Replace failing motif with the next in the hierarchy
            local nextMotifIndex = (currentMotifIndex % #motifKeys) + 1
            solution[failIndex] = motifKeys[nextMotifIndex]

            -- Increase the length of the solution if the end of the motifKeys list is reached
            if nextMotifIndex == 1 then
                n = n + 1
                solution = createSolution(n)
            end
        end

    elseif status == "win" then
        emu.print("Win state achieved with current solution!")
        appendSolutionToFile(solution)
        break -- Exit the loop if win state is achieved
    end
until status == "win"


-- At this point, solution should be feasible
