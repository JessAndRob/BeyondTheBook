# we need a module and then to install PowerShell Universla
# as admin
Install-Module Universal
Install-PSUServer # installs universal as a service so need to run this as admin

# to upgrade
Update-Module Universal
Update-PSUServer

# check out the service
Get-Service PowerShellUniversal

## open the web portal
Start-Process "http://localhost:5000"

##########
## APIS ##
##########

# create a new api in the web portal
# name: 

# call the api endpoint
Invoke-RestMethod -Uri "http://localhost:5000/hello-world" -Method Get

# lets create a more useful one to get SqlInstance information
# path: /SQLInstances/GetSqlInstances
# script: 
Connect-DbaInstance -SqlInstance sql1,sql2,sql3 | select SqlInstance,VersionString,EngineEdition,Edition,HostDistribution

# lets call it from here
Invoke-RestMethod -Uri "http://localhost:5000/SQLInstances/GetSqlInstances" -Method Get

# and lets create one to get database information
# path: /Databases/GetDatabases
# script:
Get-DbaDatabase -SqlInstance sql1 | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,Trustworthy,PageVerify,AutoShrink,AutoClose 
# lets call it from here
Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases" -Method Get

# we can add a parameter to the api so we can pass in the sql instance
# path: /Databases/GetDatabases/:sqlinstance
    # the :sqlinstance becomes $sqlinstance
# script:
Get-DbaDatabase -SqlInstance $sqlinstance | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,Trustworthy,PageVerify,AutoShrink,AutoClose 

# we can test that with this call
Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases/sql1" -Method Get
Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases/sql2" -Method Get

# we can also pass in the SQLInstance as a body
# lets modify this path
# path: /Databases/GetDatabases
# script:
$inputData = $body | ConvertFrom-Json -Depth 10
Get-DbaDatabase -SqlInstance $inputData.SqlInstance | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,Trustworthy,PageVerify,AutoShrink,AutoClose

# and call that with the body parameter
Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases" -Method Get -Body '{"sqlinstance":"sql1"}' -ContentType 'application/json'

# what if we pass in an invalid parameter?
Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases" -Method Get -Body '{"server":"sql1"}' -ContentType 'application/json'

# It's ugly - what did we learn earlier?!? 
# we can add a try catch block to handle this
# path: /Databases/GetDatabases
# script:
try {
    $inputData = $body | ConvertFrom-Json -Depth 10
    Get-DbaDatabase -SqlInstance $inputData.SqlInstance | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,Trustworthy,PageVerify,AutoShrink,AutoClose
} catch {
    return $_.Exception.Message
}

# we could also validate the input
try {
    $inputData = $body | ConvertFrom-Json -Depth 10
    
    if($inputData -notcontains "SqlInstance") {
        return "Please provide a SqlInstance in the body of the request"
    }
    Get-DbaDatabase -SqlInstance $inputData.SqlInstance | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup,Trustworthy,PageVerify,AutoShrink,AutoClose
} catch {
    return $_.Exception.Message
}

## alright one final endpoint we need for our dashboard is to take a backup
# path: /Databases/Backup
# method: POST
# script:
try {
    $inputData = $body | ConvertFrom-Json -Depth 10

    if(-not ($inputData.SqlInstance)) {
        return "Please provide a SqlInstance"
    }
    if(-not ($inputData.Database)) {
        return "Please provide a Database"
    }
    if($inputData.BackupType) {
        $backupType = $inputData.BackupType
    } else {
        # default to Full
        $backupType = "Full"
    }

    Backup-DbaDatabase -SqlInstance $inputData.SqlInstance -Database $inputData.Database -Type $backupType | Select-Object SqlInstance, Database, Start, End, Type, BackupComplete, BackupFile
    
} catch {
    return $_.Exception.Message
}

# lets do a backup from an api call
Invoke-RestMethod -Uri "http://localhost:5000/Databases/Backup" -Method Post -Body '{"SqlInstance":"sql1","Database":"msdb"}' -ContentType 'application/json'


