Write-PSFMessage -Level Host "Starting script"

Write-PSFMessage -Level Host "Create a file"
try {
    New-Item -Path "C:\Temp\test.txt" -ItemType File -ErrorAction Stop
    Write-PSFMessage -Level Host "Do something with the file"
}
catch {
    Stop-PSFFunction -Message "An error occurred: $_"
}
finally {
    Write-PSFMessage -Level Host "End of script"
}

#TODO: this generate a warning as is, or if you add a -EnableException $true it throws an error but out of order 

