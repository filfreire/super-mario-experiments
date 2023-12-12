emu.print("Hello from Lua!")

while true do
    local marioVerticalPosition = memory.readbyte(0x00CE)

    -- advance 10 frames
    for i=1,30 do
        joypad.set(1, {right=true})
        emu.frameadvance()
    end

    for j=1,30 do
        joypad.set(1, {A=true})
        emu.frameadvance()
    end

end
