## PSDefaultParameterValues
# The $PSDefaultParameterValues preference variable lets you specify custom default values for any cmdlet or advanced function.

get-help about_Parameters_DefaultValues

# we can get a list of databases from a sql server like this with a sql credential #TODO: do we have one to use?
$cred = Get-Credential sqladmin
Get-DbaDatabase -SqlInstance mssql1 -SqlCredential $cred

# but we either need to save the connection to a variable, or pass in the credential each time
# instead we can set the default value for the SqlCredential parameter

# this sets the default value for the SqlCredential parameter only for the Get-DbaDatabase cmdlet
$PSDefaultParameterValues = @{
    'Get-DbaDatabase:SqlCredential' = $cred
}

# view the default parameter values
$PSDefaultParameterValues

# now we can just call the cmdlet without the SqlCredential parameter
Get-DbaDatabase -SqlInstance mssql1

# we can also set the default value for all cmdlets that have a SqlCredential parameter
$PSDefaultParameterValues = @{
    '*:SqlCredential' = $cred
}

# view the default parameter values
$PSDefaultParameterValues

# now we can call any cmdlet that has a SqlCredential parameter without passing it in
Invoke-DbaQuery -SqlInstance mssql1 -Query 'SELECT SUSER_NAME() as WhoAmI'

# we can also add to the default values instead of replacing them
$PSDefaultParameterValues += @{
    '*-Dba*:SqlInstance' = 'mssql1'
}

# view the default parameter values
$PSDefaultParameterValues

# now we can call any cmdlet that has a SqlInstance parameter without passing it in
Get-DbaAgentJob

## I use this a lot when I'm working with SQL Server in containers - with SQL Credentials
Start-Process 'https://jesspomfret.com/psdefaultparametervaluescontainers/'