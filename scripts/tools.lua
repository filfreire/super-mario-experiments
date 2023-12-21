-- Function that given a motif, executes it for a given number of frames
function executeMotif(motif, frames)
    for i = 1, frames do
        joypad.set(1, motif)
        emu.frameadvance()
    end
end


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
end

-- Function to concatenate elements of the solution table into a string
function solutionToString(solution)
    local str = ""
    for i, motifData in ipairs(solution) do
        str = str .. motifData.motif .. ":" .. motifData.duration
        if i < #solution then
            str = str .. ", "
        end
    end
    return str
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
        file:write(solutionToString(solution) .. "\n")
        file:close()
    else
        print("Unable to open or create the file.")
    end
end

-- load solution from a file

function loadSolutionFromFile(filename)
    local lfs = require("lfs")
    local currentDirectory = lfs.currentdir()

    local fullPath = currentDirectory .. "\\..\\" .. filename
    print("The file path is: " .. fullPath)

    local file = io.open(fullPath, "r")

    if file then
        local solution = {}
        for line in file:lines() do -- TODO: ignore for now multiple lines
            solution = parseSolutionString(line)
        end
        file:close()
        return solution
    else
        print("Unable to open or create the file.")
    end
end

-- parse string like "rightA:20, right:10, right:20, right:10" into solution table
function parseSolutionString(solutionString)
    local solution = {}
    -- trim spaces from solutionString
    solutionString = solutionString:gsub("^%s*(.-)%s*$", "%1")
    for motif, duration in solutionString:gmatch("(%w+):(%d+)") do
        table.insert(solution, {
            motif = motif,
            duration = tonumber(duration)
        })
    end
    return solution
end

-- Function to get the current position of Mario
function getCurrentMarioPosition()
    local marioVerticalPosition = memory.readbyte(0x00CE)
    local marioVerticalMultiplier = memory.readbyte(0x00B5)

    local marioHorinzontalPosition = memory.readbyte(0x0086)
    local marioHorinzontalMultiplier = memory.readbyte(0x006D)

    return marioHorinzontalPosition + (256 * marioHorinzontalMultiplier),
        marioVerticalPosition + (256 * marioVerticalMultiplier)
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

-- Function to execute a solution
function executeSolution(solution, goalXPosition, motifs)
    local lastPosition = getCurrentMarioPosition()
    for i, motifData in ipairs(solution) do

        executeMotif(motifs[motifData.motif], motifData.duration) -- Execute the motif with the specified duration

        local currentPositionX, currentPositionY = getCurrentMarioPosition()

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
            return "win", i -- Return win status, and current motif that reached the goal, to catch redudant motifs
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

-- Function to reset the current level
function resetCurrentLevel()
    -- set memory 0x0772 to 0x00
    memory.writebyte(0x0772, 0x01)
    -- advance 30 frames to wait for level to reset (.5 secs)
    for i = 1, 30 do
        emu.frameadvance()
    end
end

-- get game timer value, 0x07F8/A 	Digits of Game Timer (0100 0000 0000) in BCD Format.
function getCurrentGameTimer()
    local gameTimer = memory.readbyte(0x07F8) * 100 + memory.readbyte(0x07F9) * 10 + memory.readbyte(0x07FA)

    return gameTimer
end


-- Function to clone a solution
-- TODO: not sure if this is needed
function cloneSolution(solution)
    local newSolution = {}
    for i, motifData in ipairs(solution) do
        newSolution[i] = motifData
    end
    return newSolution
end


function calculateHeuristicScore(start, finish, current)
    -- Ensure that start is not equal to finish to avoid division by zero
    if start == finish then
        return 0
    end

    -- Calculate the relative position of current
    local relativePosition = (current - start) / (finish - start)

    -- Scale to 0 - 100 range
    local score = relativePosition * 100

    -- Clamp the score to the 0-100 range
    if score < 0 then
        return 0
    elseif score > 100 then
        return 100
    else
        return score
    end
end


return {
    debugMarioPosition = debugMarioPosition,
    solutionToString = solutionToString,
    appendSolutionToFile = appendSolutionToFile,
    getCurrentMarioPosition = getCurrentMarioPosition,
    loadSolutionFromFile = loadSolutionFromFile,
    executeMotif = executeMotif,
    executeSolution = executeSolution,
    findInTable = findInTable,
    checkIfFailState = checkIfFailState,
    checkIfWinState = checkIfWinState,
    parseSolutionString = parseSolutionString,
    resetCurrentLevel = resetCurrentLevel,
    getCurrentGameTimer = getCurrentGameTimer,
    cloneSolution = cloneSolution,
    calculateHeuristicScore = calculateHeuristicScore
}
