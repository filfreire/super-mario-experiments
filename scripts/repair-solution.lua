local tools = require("tools")
local m = require("motifs")

function repairSolution(solution, goalXPosition, saveToRestart, maxRepairAttempts)
    if maxRepairAttempts == nil then
        maxRepairAttempts = 100 -- default to 100
    end
    local currentRepairAttempts = 0
    repeat
        savestate.load(saveToRestart)
        local status, index = tools.executeSolution(solution, goalXPosition, m.motifs)
        local currentPositionX, currentPositionY = tools.getCurrentMarioPosition()
        if status == "fail" or status == "stuck" then
            -- emu.print("Repairing solution attempt..." .. currentRepairAttempts .. " of " .. maxRepairAttempts)
            currentRepairAttempts = currentRepairAttempts + 1
            if index then
                local currentMotifData = solution[index]
                local currentMotifIndex = tools.findInTable(m.motifKeys, currentMotifData.motif)
                local currentFrameDurationIndex = tools.findInTable(m.frameDurations, currentMotifData.duration)

                -- Cycle through motifs and frame durations before increasing length of solution
                if currentFrameDurationIndex < #m.frameDurations then
                    currentMotifData.duration = m.frameDurations[currentFrameDurationIndex + 1]
                else
                    currentMotifData.duration = m.frameDurations[1]
                    currentMotifData.motif = m.motifKeys[(currentMotifIndex % #m.motifKeys) + 1]
                end
            end
        end
    until currentRepairAttempts >= maxRepairAttempts or status == "win"
    return solution, index
end

return {
    repairSolution = repairSolution
}
