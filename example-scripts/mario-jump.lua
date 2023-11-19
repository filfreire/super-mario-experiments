emu.print("Hello from Lua!")

while true do
    local marioVerticalPosition = memory.readbyte(0x00CE)

    emu.print("Mario's vertical position is: " .. marioVerticalPosition)

    if marioVerticalPosition == 176 then
        joypad.set(1, {A=true})
    else
        joypad.set(1, {A=false})
    end

    -- advance 10 frames
    for i=1,10 do
        emu.frameadvance()
    end
end
