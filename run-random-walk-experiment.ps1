# Loop from 1 to 15
for ($index = 16; $index -le 30; $index++) {
    # Calculate processor affinity
    $processorAffinity = [Math]::Pow(2, $index % 16)

    # Call the script with the current index and processor affinity
    .\generate-initial-solution-RW.ps1 $index $processorAffinity
}