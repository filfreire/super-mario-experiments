local tools = require("tools")
local m = require("motifs")
local repair = require("repair-solution")

emu.speedmode("maximum")

-- TODO: make these proper env variables
local RANDOM_SEED = 42
local RANDOM_MUTATION_COUNT = 100
math.randomseed(RANDOM_SEED)
local segmentGap = 1
local bestTimerYet = 0
local FILENAME_TO_SAVE_SOLUTION = "..\\data\\solutions-mutation-only.txt"

-- TODO: make this env variable
local GOAL_POSITION = 3161 -- win position SMB Level 1-1
local START_POSITION, _ = tools.getCurrentMarioPosition()

emu.print("Start position X: " .. START_POSITION .. " - Goal position X: " .. GOAL_POSITION)

local thresholdHeuristicValue = 20 -- Define a threshold for low heuristic value

local playbackFilename = os.getenv("playbackFilename")
if playbackFilename == nil then
    emu.print("playbackFilename env variable not set")
    return
end

-- Function to find segments
local function findSegments(numbers, gap)
    local segments = {}
    local currentSegment = {numbers[1]}

    for i = 2, #numbers do
        if numbers[i] - numbers[i - 1] <= gap then
            table.insert(currentSegment, numbers[i])
        else
            table.insert(segments, currentSegment)
            currentSegment = {numbers[i]}
        end
    end
    table.insert(segments, currentSegment)
    return segments
end

local solution = tools.loadSolutionFromFile(playbackFilename)
emu.print("Solution loaded: " .. tools.solutionToString(solution) .. " - Length: " .. #solution .. " motifs")

tools.resetCurrentLevel()
local initialSave = savestate.create(1)
savestate.save(initialSave)

-- heuristic function - check heuristic score before and after motif, return difference
local function evaluateMotif(motifData)
    local initialPositionX, _ = tools.getCurrentMarioPosition()
    tools.executeMotif(m.motifs[motifData.motif], motifData.duration)
    local finalPositionX, _ = tools.getCurrentMarioPosition()
    local initialHeuristicScore = tools.calculateHeuristicScore(START_POSITION, GOAL_POSITION, initialPositionX)
    local currentHeuristicScore = tools.calculateHeuristicScore(START_POSITION, GOAL_POSITION, finalPositionX)
    local difference = (currentHeuristicScore - initialHeuristicScore)
    -- emu.print("difference: " .. difference * 100) -- for now multiplying by 100 to make it easier to spot large diffs
    return difference * 100
end

function mutateSolution(solution, heuristicValues, segmentToMutate)
    local mutatedSolution = {}
    -- for each motif, if they are motif with low heuristic value, mutate them by picking a random motif and duration, otherwise keep them as they are and store into a new list
    for i, motifData in ipairs(solution) do

        if tools.findInTable(segmentToMutate, i) then
            local randomMotif = m.motifKeys[math.random(#m.motifKeys)]
            local randomDuration = m.frameDurations[math.random(#m.frameDurations)]
            table.insert(mutatedSolution, {
                motif = randomMotif,
                duration = randomDuration
            })
        else
            table.insert(mutatedSolution, motifData)
        end
    end
    savestate.load(initialSave)

    -- check if mutated solution has better heuristic value than original solution for the mutated motifs
    for i, motifData in ipairs(mutatedSolution) do
        if tools.findInTable(segmentToMutate, i) then
            local originalHeuristicValue = heuristicValues[i]
            local mutatedHeuristicValue = evaluateMotif(motifData)
            if mutatedHeuristicValue > originalHeuristicValue then
                -- If the unique mutation results in a faster heuristic at this segment, we consider solution mutation successful (even if its not feasible yet)
                -- emu.print("Mutated solution with higher heuristic score! ")
                return mutatedSolution
            end
        end
    end

    return nil
end

function generateCrossover(candidateSolution, mutatedSolutions)
    local crossoverSolution = {}
    -- Create a table to keep track of which positions have been filled
    local filledPositions = {}
    for i, mutatedSolution in ipairs(mutatedSolutions) do
        for j, motifData in ipairs(mutatedSolution) do
            -- Check if this position has not been filled yet
            if not filledPositions[j] then
                if motifData.motif == candidateSolution[j].motif and motifData.duration == candidateSolution[j].duration then
                    -- If the fields are the same, insert from candidateSolution and mark position as filled
                    crossoverSolution[j] = candidateSolution[j]
                    filledPositions[j] = true
                else
                    -- If the fields are different, insert from mutatedSolution and mark position as filled
                    crossoverSolution[j] = motifData
                    filledPositions[j] = true
                end
            end
            -- If the position is already filled, do nothing
        end
    end
    return crossoverSolution
end

-- Copy the solution
local initialSolution = tools.cloneSolution(solution)

-- Store heuristic values
local heuristicValues = {}
local startFramecount = emu.framecount()
for i, motifData in ipairs(initialSolution) do
    heuristicValues[i] = evaluateMotif(motifData)
end
local finishFramecount = emu.framecount()
emu.print("Frames elapsed: " .. (finishFramecount - startFramecount) .. " - Aprox. time (seconds): " ..
              (finishFramecount - startFramecount) / 60)

if bestTimerYet < tools.getCurrentGameTimer() then
    bestTimerYet = tools.getCurrentGameTimer()
    emu.print("Best timer yet: " .. bestTimerYet)
end

-- Filter motifs with low heuristic values
local lowHeuristicMotifs = {}
for motif, value in pairs(heuristicValues) do
    if value < thresholdHeuristicValue then
        table.insert(lowHeuristicMotifs, motif)
    end
end

emu.print("Low heuristic motifs: " .. table.concat(lowHeuristicMotifs, ", ") .. " - Length: " .. #lowHeuristicMotifs)

local feasible_count = 0
local population = {}

-- initial population of 10000 with initialSolution
for i = 1, 1000 do
    table.insert(population, tools.cloneSolution(initialSolution))
end

local feasible_count = 0

repeat
    for i, solution in ipairs(population) do
        emu.print("Trying to create feasible solution " .. i .. " of " .. #population)
        -- MUTATION: for each segment create a mutation and store it in a list of mutated solutions
        local segments = findSegments(lowHeuristicMotifs, segmentGap)
        local mutatedSolutions = {}
        for i, segment in ipairs(segments) do
            -- do 100 attempts at a different mutation of same segment
            for i = 1, RANDOM_MUTATION_COUNT do
                local mutatedSolution = mutateSolution(solution, heuristicValues, segment)
                if mutatedSolution ~= nil then
                    table.insert(mutatedSolutions, mutatedSolution)
                end
            end
        end

        for i, mutatedSolution in ipairs(mutatedSolutions) do
            savestate.load(initialSave)
            local startFramecount = emu.framecount()
            local status, indexWhenDone = tools.executeSolution(mutatedSolution, GOAL_POSITION, m.motifs)
            local finishFramecount = emu.framecount()
            if status == "win" then
                feasible_count = feasible_count + 1
                local timerstring = "+timer:" .. tools.getCurrentGameTimer()
                local solutionstring = tools.solutionToString(mutatedSolution)
                local indexstring = "+index:" .. indexWhenDone
                local somestring = timerstring .. indexstring .. "|" .. solutionstring

                emu.print(somestring)
                tools.appendStringToFile(somestring, FILENAME_TO_SAVE_SOLUTION)
            end
        end
    end
    emu.print("Feasible solutions: " .. feasible_count)
until true

emu.print("done...")
emu.pause()

return
