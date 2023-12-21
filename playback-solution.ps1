# Created by Filipe Freire, 2023
# This script replays a solution for the SMB game

$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-playback-solution.lua"

$fileName = $args[0]
if ($null -eq $fileName) {
    Write-Host "No file name provided"
    exit
}

# set filename as env variable
$env:playbackFilename = $fileName

fceux.exe -loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes