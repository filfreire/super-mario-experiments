emu.print("Start!")

-- function that prints the current position of Mario
function debugMarioPosition()
    local marioVerticalPosition = memory.readbyte(0x00CE)
    local marioVerticalMultiplier = memory.readbyte(0x00B5)

    local marioHorinzontalPosition = memory.readbyte(0x0086)
    local marioHorinzontalMultiplier =  memory.readbyte(0x006D)

    -- local notsurePosX = memory.readbyte(0x03AD)
    -- local notsurePosX2 = memory.readbyte(0x071D)
    --emu.print("Not sure: " .. notsurePosX .. ", " .. notsurePosX2)

    local playerState = memory.readbyte(0x000E)
    local playingDeathMusic = memory.readbyte(0x0712)
    -- 8 normal
    -- 6 game over
    -- 11 dead via enemy
    -- playingDeathMusic 1 is when falling into a hole and dying

    emu.print("Mario position total: " .. (marioHorinzontalPosition + (256 *  marioHorinzontalMultiplier))  .. ", " .. (marioVerticalPosition + (256 *  marioVerticalMultiplier)))
    -- emu.print("Mario position: " .. marioHorinzontalPosition .. ", " .. marioVerticalPosition .. ", " .. marioHorinzontalMultiplier .. ", " .. marioVerticalMultiplier)
    emu.print("Player state/playing death music: " .. playerState .. ", " .. playingDeathMusic)

end

-- function that given a motif, executes it for a given number of frames
function executeMotif(motif, frames)
    for i=1,frames do
        joypad.set(1, motif)
        emu.frameadvance()
    end
    -- emu.print("Executed motif: " .. tostring(motif) .. " for " .. frames .. " frames")
end

-- L1.1 ending coordinates X 89*12 = 1068
local motif1 = {right = true, A = true, B = true}
local motif2 = {right = true, A = true, B = false}
local motif3 = {right = true, A = false, B = true}
local motif4 = {right = true, A = false, B = false}

-- main loop
while true do

    -- print mario position
    debugMarioPosition()

    executeMotif(motif1, 10)
    executeMotif(motif2, 10)
    executeMotif(motif3, 10)
    executeMotif(motif4, 10)

end
