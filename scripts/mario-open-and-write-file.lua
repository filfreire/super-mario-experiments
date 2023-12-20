emu.print("Start!")

emu.print(os.getenv("foo"))

local lfs = require("lfs")
local currentDirectory = lfs.currentdir()

local fileName = "..\\data\\random.txt"
local fullPath = currentDirectory .. "\\" .. fileName
print("The file path is: " .. fullPath)

local file = io.open(fileName, "w")

if file then
    file:write("hello world")
    file:close()
else
    print("Unable to open or create the file.")
end

-- main loop
while true do
    emu.frameadvance()
end
