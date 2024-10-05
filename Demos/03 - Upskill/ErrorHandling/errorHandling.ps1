####################
## Error Handling ##
####################

# Error handling is a critical part of any script. It allows you to gracefully handle errors and provide feedback to the user.
# copilot wrote that ;) 

# works perfectly fine
New-Item -Path "C:\Temp\test.txt" -ItemType File

# but the second time... not so good
New-Item -Path "C:\Temp\test.txt" -ItemType File

# we can fix it 
New-Item -Path "C:\Temp\test.txt" -ItemType File -ErrorAction SilentlyContinue

# This is bad! Don't do this!

# Instead we should make our scripts idempotent. This means that we can run the script multiple times and it will always end up in the same state.
# We can do this by checking if the file exists before creating it.
if (-not (Test-Path -Path "C:\Temp\test.txt")) {
    New-Item -Path "C:\Temp\test.txt" -ItemType File
}

## Let's talk about flow control

# If this is a script we want to control what happens when we enc
code '.\Demos\02 - Upskill\ErrorHandling\script.ps1'

# lets run it as it is so far
& '.\Demos\02 - Upskill\ErrorHandling\script.ps1'

# if it errors it still carries on and does the rest of what is in the script - probably not ideal

# So we can use try/catch blocks to handle errors and control the flow of the script
try {
    New-Item -Path "C:\Temp\test.txt" -ItemType File
}
catch {
    Write-Error "Failed to create file: $_"
}

# and we can handle specific errors
try {
    New-Item -Path "C:\Temp\test.txt" -ItemType File
}
catch [System.UnauthorizedAccessException] {
    Write-Error "You do not have permission to create the file"
}
catch [System.IO.IOException] {
    Write-Error "The file already exists"
}
catch {
    Write-Error "An error occurred: $_"
}

# we can also have a finally block that will always run
try {
    New-Item -Path "C:\Temp\test.txt" -ItemType File
}
catch {
    Write-Error "An error occurred: $_"
}
finally {
    Write-Host "This will always run"
}

# lets improve our script some 
code '.\Demos\02 - Upskill\ErrorHandling\script_v2.ps1'

# and run it
& '.\Demos\02 - Upskill\ErrorHandling\script_v2.ps1'

## umm??
## Q: What happened? Why did it run the rest of the script still?














## A: PowerShell will only catch terminating errors by default.
## and New-Item does not throw a terminating error when the file already exists.

# We can change this behaviour by setting the ErrorAction parameter to Stop

code '.\Demos\02 - Upskill\ErrorHandling\script_v3.ps1'

# and run it
& '.\Demos\02 - Upskill\ErrorHandling\script_v3.ps1'


#################
## PSFramework ##
#################

# we also have a great community module called PSFramework that can help with error handling and logging
# https://psframework.org/

Import-Module PSFramework

# lets view the commands available
Get-Command -Module PSFramework

Write-PSFMessage -Level Critical -Message "This is an error message"
Write-PSFMessage -Level Warning -Message "This is a warning message"
Write-PSFMessage -Level Verbose -Message "This is a verbose message"
## we need to have verbose preference set to continue to see verbose messages
$VerbosePreference = 'Continue'
Write-PSFMessage -Level Verbose -Message "This is a verbose message"
## lets turn it off again
$VerbosePreference = 'SilentlyContinue'
Write-PSFMessage -Level Verbose -Message "This is a verbose message"

# We also have Stop-PSFFunction which will stop the script and provide a message
Stop-PSFFunction -Message 'We have an error'

# so lets change our script to use PSFramework
code '.\Demos\02 - Upskill\ErrorHandling\script_v4.ps1'

# and run it
& '.\Demos\02 - Upskill\ErrorHandling\script_v4.ps1'

####################
## Bonus: Logging ##
####################

# PSFramework also has a logging module that can log messages to a file
Set-PSFLoggingProvider -Name logfile -Enabled $true -FilePath 'C:\github\PASS-BTB\Demos\02 - Upskill\ErrorHandling\log.csv'

# Now all messages in this session go to the file
Write-PSFMessage -Level Critical -Message "This is an error message"
Write-PSFMessage -Level Warning -Message "This is a warning message"
Write-PSFMessage -Level Verbose -Message "This is a verbose message"
Write-PSFMessage -Level Host -Message "This is an output message"

# now we can see the log file
code 'C:\github\PASS-BTB\Demos\02 - Upskill\ErrorHandling\log.csv'

# but we can also read it in as it's a csv
Import-CSV 'C:\github\PASS-BTB\Demos\02 - Upskill\ErrorHandling\log.csv'

# which means we can also filter it
Import-CSV 'C:\github\PASS-BTB\Demos\02 - Upskill\ErrorHandling\log.csv' | Where-Object Level -eq 'Critical'

# or group it 
Import-CSV 'C:\github\PASS-BTB\Demos\02 - Upskill\ErrorHandling\log.csv' | Group-Object Level

# lets turn off the logging provider so we don't log the rest of the precon
Set-PSFLoggingProvider -Name logfile -Enabled $false