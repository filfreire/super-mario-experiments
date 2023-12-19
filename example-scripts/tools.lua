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

function getCurrentMarioPosition()
    local marioVerticalPosition = memory.readbyte(0x00CE)
    local marioVerticalMultiplier = memory.readbyte(0x00B5)

    local marioHorinzontalPosition = memory.readbyte(0x0086)
    local marioHorinzontalMultiplier = memory.readbyte(0x006D)

    return marioHorinzontalPosition + (256 * marioHorinzontalMultiplier),
        marioVerticalPosition + (256 * marioVerticalMultiplier)
end

return {
    debugMarioPosition = debugMarioPosition,
    solutionToString = solutionToString,
    appendSolutionToFile = appendSolutionToFile,
    getCurrentMarioPosition = getCurrentMarioPosition
}
