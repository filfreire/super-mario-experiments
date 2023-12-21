# Created by Filipe Freire, 2023
# This script generates an feasible initial solution for the SMB game

$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-initial-generation.lua"
fceux.exe -loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes
