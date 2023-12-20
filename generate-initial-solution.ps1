# Created by Filipe Freire, 2023
# This script generates an feasible initial solution for the SMB game

fceux.exe -loadstate .\savestates\smb.fc0 -lua C:\Users\filipe\Desktop\metaheuristics\super-mario-experiments\scripts\mario-initial-generation.lua -bginput 1 .\roms\smb.nes
