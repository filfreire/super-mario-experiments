local tools = require("tools")
local m = require("motifs")

emu.speedmode("maximum")


-- TODO: make this env variable
local goalXPosition = 3161 -- win position SMB Level 1-1

local playbackFilename = os.getenv("playbackFilename")
if playbackFilename == nil then
    emu.print("playbackFilename env variable not set")
    return
end

local solution = tools.loadSolutionFromFile(playbackFilename)
emu.print("Solution loaded: " .. tools.solutionToString(solution))

tools.resetCurrentLevel()

local startPositionX, startPositionY = tools.getCurrentMarioPosition()
emu.print("Start position X: " .. startPositionX)

local startFramecount = emu.framecount()
status, failIndex = tools.executeSolution(solution, goalXPosition, m.motifs)
local finishFramecount = emu.framecount()
emu.print("Status: " .. status)
emu.print("Frames elapsed: " .. (finishFramecount - startFramecount) .. " - Aprox. time (seconds): " ..
              (finishFramecount - startFramecount) / 60)

emu.print("Game timer: " .. tools.getCurrentGameTimer())


emu.pause()
return
