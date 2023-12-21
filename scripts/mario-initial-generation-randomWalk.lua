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

-- Random seed from environment variable
local randomSeed = os.getenv("randomSeed")
if randomSeed == nil then
    emu.print("randomSeed env variable not set")
    return
end

math.randomseed(randomSeed)

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

local iteration = 0

-- Main Cyclic random walk generation algorithm
local solution = createSolution(n) -- initialize solution with length n
repeat
    local status, failIndex = tools.executeSolution(solution, goalXPosition, m.motifs)

    local currentPositionX, currentPositionY = tools.getCurrentMarioPosition()

    if currentPositionX > farthestPosition then
        farthestPosition = currentPositionX
        bestSolutionYet = solution
        emu.print("Goal position: " .. goalXPosition .. ", Farthest position: " .. farthestPosition)
        emu.print("Best solution yet: " .. tools.solutionToString(bestSolutionYet))
        tools.appendStringToFile(
            farthestPosition .. "|" .. randomSeed .. "|" .. tools.solutionToString(bestSolutionYet) .. "\n",
            "..\\data\\solutions-bestSolutionYet-randseed-" .. randomSeed .. ".txt")
    end

    tools.appendStringToFile(iteration .. "," .. farthestPosition, "..\\data\\random-walk" .. randomSeed .. ".txt")
    iteration = iteration + 1

    if status == "fail" or status == "stuck" then
        savestate.load(initialSave)

        if failIndex then
            local currentMotifData = solution[failIndex]
            local currentMotifIndex = tools.findInTable(m.motifKeys, currentMotifData.motif)
            local currentFrameDurationIndex = tools.findInTable(m.frameDurations, currentMotifData.duration)

            -- Cycle through motifs and frame durations randomly before increasing length of solution
            currentMotifData.motif = m.motifKeys[math.random(#m.motifKeys)]
            currentMotifData.duration = m.frameDurations[math.random(#m.frameDurations)]
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
        tools.appendSolutionToFile(solution, "..\\data\\solutions-winning-solutions-randseed-" .. randomSeed .. ".txt")
        finalSolution = solution
        break
    end
until status == "win"

-- At this point, finalSolution should be feasible
emu.print("Final feasible solution found: " .. tools.solutionToString(finalSolution))
emu.pause()
