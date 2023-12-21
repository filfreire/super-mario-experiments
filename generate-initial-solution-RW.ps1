# Created by Filipe Freire, 2023
# This script generates an feasible initial solution for the SMB game




$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-initial-generation-randomWalk.lua"


$randomSeed = $args[0]
if ($null -eq $randomSeed) {
    Write-Host "No randomSeed provided"
    exit
}

# set randomSeed as env variable
$env:randomSeed = $randomSeed

fceux.exe -loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes
