# Created by Filipe Freire, 2023
# This script generates an feasible initial solution for the SMB game

$scriptPath = $PSScriptRoot
$fullLuaScriptPath = Join-Path -Path $scriptPath -ChildPath "\scripts\mario-initial-generation-randomWalk.lua"

$randomSeed = $args[0]
$processorAffinity = $args[1]

if ($null -eq $randomSeed) {
    Write-Host "No randomSeed provided"
    exit
}

if ($null -eq $processorAffinity) {
    Write-Host "No processorAffinity provided"
    exit
}


# set randomSeed as env variable
$env:randomSeed = $randomSeed


# Start fceux.exe with specified processor affinity
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = "fceux.exe"
$processStartInfo.Arguments = "-loadstate .\savestates\smb.fc0 -lua $fullLuaScriptPath -bginput 1 .\roms\smb.nes"
$processStartInfo.UseShellExecute = $false

$process = [System.Diagnostics.Process]::Start($processStartInfo)

# Convert processorAffinity to int32 then to IntPtr
$affinityMask = [int32]$processorAffinity
$process.ProcessorAffinity = [IntPtr]$affinityMask