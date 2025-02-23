Write-Output "Starting script"

Write-Output "Create a file"
try {
    New-Item -Path "C:\Temp\test.txt" -ItemType File -ErrorAction Stop
    Write-Output "Do something with the file"
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Output "End of script"
}

