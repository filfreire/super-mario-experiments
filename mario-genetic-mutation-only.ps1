# Created by Filipe Freire, 2023
# mutation only version of mario-genetic-1.ps1

$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-genetic-mutation-only.lua"

$fileName = $args[0]
if ($null -eq $fileName) {
    Write-Host "No file name provided"
    exit
}

# set filename as env variable
$env:playbackFilename = $fileName

fceux.exe -loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes