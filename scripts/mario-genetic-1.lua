local tools = require("tools")
local m = require("motifs")

emu.speedmode("maximum")

-- TODO: make this env variable
local RANDOM_SEED = 42
math.randomseed(RANDOM_SEED)
local segmentGap = 1

local bestTimerYet = 999



-- TODO: make this env variable
local goalXPosition = 3161 -- win position SMB Level 1-1
local thresholdHeuristicValue = 5 -- Define a threshold for low heuristic value

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

-- heuristic function - for now we check if this motif makes Mario closer to the objective
-- in the original paper they seem to use some sort of conversion of this from 0 to 100
local function evaluateMotif(motifData)
    local initialPositionX, initialPositionY = tools.getCurrentMarioPosition()
    tools.executeMotif(m.motifs[motifData.motif], motifData.duration)
    local finalPositionX, finalPositionY = tools.getCurrentMarioPosition()
    return finalPositionX - initialPositionX
end

local function cloneSolution(solution)
    local solutionCopy = {}
    for i, motifData in ipairs(solution) do
        solutionCopy[i] = motifData
    end
    return solutionCopy
end

local function mutateSolution(solution, lowHeuristicMotifsIndexes)
    local mutatedSolution = {}
    -- for each motif, if they are motif with low heuristic value, mutate them by picking a random motif and duration, otherwise keep them as they are and store into a new list
    for i, motifData in ipairs(solution) do

        if tools.findInTable(lowHeuristicMotifsIndexes, i) then
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

    return mutatedSolution
end

-- Copy the solution
local solutionCopy = cloneSolution(solution)

local startFramecount = emu.framecount()
-- Store heuristic values
local heuristicValues = {}
for i, motifData in ipairs(solutionCopy) do
    heuristicValues[i] = evaluateMotif(motifData)
end
local finishFramecount = emu.framecount()
emu.print("Frames elapsed: " .. (finishFramecount - startFramecount) .. " - Aprox. time (seconds): " ..
              (finishFramecount - startFramecount) / 60)

if bestTimerYet > tools.getCurrentGameTimer() then
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

emu.print("Low heuristic motifs: " .. table.concat(lowHeuristicMotifs, ", "))


-- Finding the segments
local segments = findSegments(lowHeuristicMotifs, segmentGap)

local success_count = 0

for i, segment in ipairs(segments) do
    print("Segment " .. i .. ": " .. table.concat(segment, ", "))
     for j = 1, 30 do
        savestate.load(initialSave)
        local startFramecount = emu.framecount()
        local mutatedSolution = mutateSolution(solutionCopy, segment)
        status, indexWhenDone = tools.executeSolution(mutatedSolution, goalXPosition, m.motifs)
        local finishFramecount = emu.framecount()

        --emu.print("mutated " .. i ..",".. j .. " - Status: " .. status)
        if status == "win" then
            success_count = success_count + 1
            emu.print("mutated " .. i ..",".. j .. " - index when done: " .. indexWhenDone)
            emu.print("Frames elapsed: " .. (finishFramecount - startFramecount) .. " - Aprox. time (seconds): " ..
              (finishFramecount - startFramecount) / 60)
            if bestTimerYet > tools.getCurrentGameTimer() then
                bestTimerYet = tools.getCurrentGameTimer()
                emu.print("Best timer yet: " .. bestTimerYet)
            end
        end
     end
end


-- try 1000 mutated solutions
-- local success_count = 0
-- local fail_count = 0
-- local stuck_count = 0

-- for i = 1, 1000 do
--     savestate.load(initialSave)
--     local mutatedSolution = mutateSolution(solutionCopy, lowHeuristicMotifs)
--     status, failIndex = tools.executeSolution(mutatedSolution, goalXPosition, m.motifs)
--     if status == "win" then
--         success_count = success_count + 1
--     elseif status == "fail" then
--         fail_count = fail_count + 1
--     elseif status == "stuck" then
--         stuck_count = stuck_count + 1
--     end
--     emu.print("Mutated solution " .. i .. " - Status: " .. status)
-- end

-- emu.print("Success count: " .. success_count .. " - Fail count: " .. fail_count .. " - Stuck count: " .. stuck_count)

emu.pause()

return
