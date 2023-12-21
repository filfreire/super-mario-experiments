local tools = require("tools")

-- set max speed on emulator
emu.speedmode("maximum")

local farthestPosition = 0
local bestSolutionYet = nil
local finalSolution = nil
local m = require("motifs")

-- TODO: make this a env variable / parameter
local n = 5 -- Starting length of the solution
local goalXPosition = 3161 -- win position


tools.resetCurrentLevel()
local initialSave = savestate.create(1)
savestate.save(initialSave)

-- Function to create a solution with the first motif+duration and length n
function createSolution(length)
    local solution = {}
    for i = 1, length do
        table.insert(solution, {
            motif = m.motifKeys[1],
            duration = m.frameDurations[1]
        })
    end
    return solution
end


-- Main Cyclic generation algorithm
local solution = createSolution(n) -- initialize solution with length n
repeat
    local status, failIndex = tools.executeSolution(solution, goalXPosition, m.motifs)

    local currentPositionX, currentPositionY = tools.getCurrentMarioPosition()

    if currentPositionX > farthestPosition then
        farthestPosition = currentPositionX
        bestSolutionYet = solution
        emu.print("Goal position: " .. goalXPosition .. ", Farthest position: " .. farthestPosition)
        emu.print("Best solution yet: " .. tools.solutionToString(bestSolutionYet))
    end


    if status == "fail" or status == "stuck" then
        savestate.load(initialSave)

        if failIndex then
            local currentMotifData = solution[failIndex]
            local currentMotifIndex = tools.findInTable(m.motifKeys, currentMotifData.motif)
            local currentFrameDurationIndex = tools.findInTable(m.frameDurations, currentMotifData.duration)

            -- Cycle through motifs and frame durations before increasing length of solution
            if currentFrameDurationIndex < #m.frameDurations then
                currentMotifData.duration = m.frameDurations[currentFrameDurationIndex + 1]
            else
                currentMotifData.duration = m.frameDurations[1]
                currentMotifData.motif = m.motifKeys[(currentMotifIndex % #m.motifKeys) + 1]
            end
        else
            -- Handle the case when failIndex is nil, increase length of solution
            table.insert(solution, {
                motif = m.motifKeys[1],
                duration = m.frameDurations[1]
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
