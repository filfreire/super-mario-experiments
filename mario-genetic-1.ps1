# Created by Filipe Freire, 2023
# This script attempts to optimize an initial solution using a Genetic Algorithm
# following the approach described in the paper "An Evolutionary Metaheuristic Algorithm to Optimise Solutions to NES Games, by Leane at al. (2017)"

$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-genetic-1.lua"

$fileName = $args[0]
if ($null -eq $fileName) {
    Write-Host "No file name provided"
    exit
}

# set filename as env variable
$env:playbackFilename = $fileName

fceux.exe -loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes