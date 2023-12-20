local tools = require("tools")
local m = require("motifs")

emu.speedmode("maximum")

-- TODO: make this env variable
local goalXPosition = 3161 -- win position SMB Level 1-1
local thresholdHeuristicValue = 10 -- Define a threshold for low heuristic value

local playbackFilename = os.getenv("playbackFilename")
if playbackFilename == nil then
    emu.print("playbackFilename env variable not set")
    return
end

local solution = tools.loadSolutionFromFile(playbackFilename)
emu.print("Solution loaded: " .. tools.solutionToString(solution) .. " - Length: " .. #solution .. " motifs")

tools.resetCurrentLevel()
local initialSave = savestate.create(1)
savestate.save(initialSave)

-- heuristic function - for now we check if this motif makes Mario closer to the objective
local function evaluateMotif(motifData)
    local initialPositionX, initialPositionY = tools.getCurrentMarioPosition()
    tools.executeMotif(m.motifs[motifData.motif], motifData.duration)
    local finalPositionX, finalPositionY = tools.getCurrentMarioPosition()
    return finalPositionX - initialPositionX
end

-- Copy the solution
local solutionCopy = {}
for i, motifData in ipairs(solution) do
    solutionCopy[i] = motifData
end

local startFramecount = emu.framecount()
-- Store heuristic values
local heuristicValues = {}
for i, motifData in ipairs(solutionCopy) do
    heuristicValues[i] = evaluateMotif(motifData)
end
local finishFramecount = emu.framecount()
emu.print("Frames elapsed: " .. (finishFramecount - startFramecount) .. " - Aprox. time (seconds): " ..
              (finishFramecount - startFramecount) / 60)

-- Filter motifs with low heuristic values
local lowHeuristicMotifs = {}
for motif, value in pairs(heuristicValues) do
    if value < threshold then
        table.insert(lowHeuristicMotifs, motif)
    end
end

emu.print("Low heuristic motifs: " .. table.concat(lowHeuristicMotifs, ", "))

emu.pause()

return
