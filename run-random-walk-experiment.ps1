# Loop from 0 to 30
for ($index = 0; $index -le 5; $index++) {
    # Call the script with the current index
    .\generate-initial-solution-RW.ps1 $index
}