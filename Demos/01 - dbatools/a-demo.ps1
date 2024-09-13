Return 'Oi, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

# This will be a quick introduction to dbatools for those that haven't used it before.

#region Getting a PowerShell module  <----- ANY PowerShell module
# How do you get it?

# Trust the repository

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# the new way
Set-PSResourceRepository -Name PSGallery -Trusted

# Install the module
$modulename = 'dbatools'
Install-Module -Name $modulename

# the new way
Install-PSResource -Name $modulename

#endregion

#region Finding commands and help <----- ANY PowerShell module
# How do you find commands?

# Get all commands in the module - This will work for any module
# Get-Command -Module $modulename
# but for dbatools, there are quite a few
Get-Command -Module $modulename | Measure-Object

# For any module you can use Get-Command with a filter to find commands
# this works for the name of the command, the noun, or the verb

Get-Command -Module $modulename -Name *login*
Get-Command -Module $modulename -Name *database*

# for dbatools, you can also use Find-DbaCommand
# this will search the command names, descriptions, and aliases
Find-DbaCommand -Pattern *login*
Find-DbaCommand -Pattern *database*

# For any module, you can use Get-Help

Get-Help Get-DbaDatabase
Get-Help Get-DbaDatabase -Full
Get-Help Get-DbaDatabase -Examples
Get-Help Get-DbaDatabase -ShowWindow

#endregion

#region Connecting to SQL Server <----- dbatools only

# How do you connect to SQL Server?

# You can use the -SqlInstance parameter on any dbatools command
# This will connect to the default instance on the local machine
Get-DbaDatabase -SqlInstance sql1

# You can also use the -SqlCredential parameter interactively

Get-DbaDatabase -SqlInstance sql1 -SqlCredential sqladmin

# You can also use the -SqlCredential parameter with a PSCredential object

$pass = ConvertTo-SecureString 'dbatools.IO!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('sqladmin', $pass)
Get-DbaDatabase -SqlInstance sql1 -SqlCredential $cred

# the Get-dba* commands will not make any changes, they will return information only

# BUT they are still running on your instance, still using resources and also connecting with your account

Get-DbaAgentJob -SqlInstance sql1
Get-DbaClientAlias
Get-DbaDbBackupHistory -SqlInstance sql1
Get-DbaDbccProcCache -SqlInstance sql1
Get-DbaFile -SqlInstance sql1

New-DbaLogin -SqlInstance sql1 -SqlCredential $cred -Login
New-DbaServerRole -SqlInstance sql1 -Role 'MyNewRole'

Add-DbaServerRoleMember

Set-DbaDbOwner
Set-DbaMaxMemory

Remove-dba

#endregion

#region More things

#region - Importing data from csv (excels, etc)
$database = "tempdb"
$table = "authors"
$csvPath = "./demos/20/authors.csv"
$delimitier = "|"

# Import the csv file to a table into the database

$splatImportCSV = @{
	SqlInstance = "dbatools1"
	Database = $database
    Table = $table
    Path = $csvPath
    Delimiter = $delimitier
    AutoCreateTable = $true
}
Import-DbaCsv @splatImportCSV


#Check if the data is there
$splatInvokeQuery = @{
	SqlInstance = "dbatools1"
	Database = $database
	Query = "SELECT * FROM $table"
}
Invoke-DbaQuery @splatInvokeQuery | Format-Table


# Not impressed?
# Let's check with a file that contains 200K rows

$csvPathBigger = "./demos/20/authors_bigger.csv"

$splatImportCSV = @{
	SqlInstance = "dbatools1"
	Database = $database
    Table = "$table-2"
    Path = $csvPathBigger
    Delimiter = $delimitier
    AutoCreateTable = $true
}
Import-DbaCsv @splatImportCSV

#NOTE:
# I suggest that you create the table with the datatypes that better match your data.
# By default columns will be created as VARCHAR(MAX).

#endregion - Importing data from csv (excels, etc)

#region multiple logins all at once
## Add Login (AD user/group)
$loginSplat = @{
    SqlInstance    = 'dbatools1'
    Login          = "JessP"
    SecurePassword = $securePassword
}
New-DbaLogin @loginSplat

##	Add User
$userSplat = @{
    SqlInstance = 'dbatools1'
    Login       = "JessP"
    Database    = "DatabaseAdmin"
}
New-DbaDbUser @userSplat

##	Add to reader role
$roleSplat = @{
    SqlInstance = 'dbatools1'
    User        = "JessP"
    Database    = "DatabaseAdmin"
    Role        = "db_datareader"
    Confirm     = $false
}
Add-DbaDbRoleMember @roleSplat

##	Change password for SQL account
$newPassword = (Read-Host -Prompt "Enter the new password" -AsSecureString)
$pwdSplat = @{
    SqlInstance    = 'dbatools1'
    Login          = "JessP"
    SecurePassword = $newPassword
}
Set-DbaLogin @pwdSplat

# Read in logins from csv
## PS4+ syntax!
(Import-Csv ./demos/18/users.csv).foreach{
    Write-Output "Adding $($psitem.User) on $($psitem.Server)"
    $server = Connect-DbaInstance -SqlInstance $psitem.Server
    New-DbaLogin -SqlInstance $server -Login $psitem.User -Password ($psitem.Password | ConvertTo-SecureString -asPlainText -Force)
    New-DbaDbUser -SqlInstance $server -Login $psitem.User -Database $psitem.Database
    Add-DbaDbRoleMember -SqlInstance $server -User $psitem.User -Database $psitem.Database -Role $psitem.Role.split(',') -Confirm:$false
}

<#
## PS Version 3 & Lower
foreach($user in $users) {
    $server = Connect-DbaInstance -SqlInstance $user.Server
    New-DbaLogin -SqlInstance $server -Login $user.User -Password ($user.Password | ConvertTo-SecureString -asPlainText -Force)
    New-DbaDbUser -SqlInstance $server -Login $user.User -Database $user.Database
    Add-DbaDbRoleMember -SqlInstance $server -User $user.User -Database $user.Database -Role $user.Role.split(',') -Confirm:$false
}
#>
#endregion multiple logins all at once

#region - copy/migrate

# Copy commands available in dbatools
Get-Command -Module dbatools -Verb Copy

## Get databases
$datatbaseSplat = @{
    SqlInstance   = 'dbatools1'
    ExcludeSystem = $true
    OutVariable   = "dbs"        # OutVariable to also capture this to use later
}
Get-DbaDatabase @datatbaseSplat |
Select-Object Name, Status, RecoveryModel, Owner, Compatibility |
Format-Table

# Get Logins
$loginSplat = @{
    SqlInstance = 'dbatools1'
}
Get-DbaLogin @loginSplat |
Select-Object SqlInstance, Name, LoginType

# Get Processes
$processSplat = @{
    SqlInstance = 'dbatools2'
    Database = $dbs.name
    ExcludeSystemSpids = $true
}
Get-DbaProcess @processSplat |
Select-Object Host, login, Program

# Kill Processes
Get-DbaProcess @processSplat | Stop-DbaProcess

## Migrate the databases
$migrateDbSplat = @{
    Source        = 'dbatools1'
    Destination   = 'dbatools2'
    Database      = $dbs.name
    BackupRestore = $true
    SharedPath    = '/shared'
    #SetSourceOffline        = $true
    Verbose       = $true
}
Copy-DbaDatabase @migrateDbSplat

## Set source dbs offline
$offlineSplat = @{
    SqlInstance = 'dbatools1'
    Database    = "Northwind", "DatabaseAdmin"
    Offline     = $true
    Force       = $true
}
Set-DbaDbState @offlineSplat

## upgrade compat level & check all is ok
$compatSplat = @{
    SqlInstance = 'dbatools2'
}
Get-DbaDbCompatibility @compatSplat |
Select-Object SqlInstance, Database, Compatibility

$compatSplat.Add('Database', 'Northwind')
$compatSplat.Add('Compatibility', '160') # need dbatools 2.0 for 160

Set-DbaDbCompatibility @compatSplat

## Upgrade database - https://thomaslarock.com/2014/06/upgrading-to-sql-server-2014-a-dozen-things-to-check/
# Updates compatibility level
# runs CHECKDB with data_purity - make sure column values are in range, e.g. datetime
# DBCC updateusage
# sp_updatestats
# sp_refreshview against all user views
$upgradeSplat = @{
    SqlInstance = 'dbatools2'
    Database    = "Pubs"
}
Invoke-DbaDbUpgrade @upgradeSplat -Force
#endregion copy/migrate

#region exporting stuff to git


$path = "./export/4"

# Export instance configuration
$splatExportInstance = @{
    SqlInstance = "dbatools1"
    Path = $path
    Exclude = @("LinkedServers", "Credentials", "CentralManagementServer", "BackupDevices", "Endpoints", "Databases", "ReplicationSettings", "PolicyManagement")
    ExcludePassword = $true
}
Export-DbaInstance @splatExportInstance

# Show folder output
# Show that passwords aren't scripted in plain text at logins.sql file


<#
    Other/optional
     - replace suffix
     - put on git
    NOTE: You can read more about this approach on my blog posts:
        Backup your SQL instances configurations to GIT with dbatools – Part 1 (https://claudioessilva.eu/2020/06/02/Backup-your-SQL-instances-configurations-to-GIT-with-dbatools-Part-1/)
        Backup your SQL instances configurations to GIT with dbatools – Part 2 – Add parallelism (https://claudioessilva.eu/2020/06/04/backup-your-sql-instances-configurations-to-git-with-dbatools-part-2-add-parallelism/)
#>
# If you want to versioning it, example put on GIT

# 1. Find .sql files where the name starts with a number and rename files to exclude numeric part "#-<NAME>.sql" (remove the "#-")
Get-ChildItem -Path $path -Recurse -Filter "*.sql" | Where-Object {$_.Name -match '^[0-9]+.*'} | Foreach-Object {Rename-Item -Path $_.FullName -NewName $($_ -split '-')[1] -Force}

# 2. Remove the suffix "-datetime"
Get-ChildItem -Path $path | ForEach-Object {Rename-Item -Path $_.FullName -NewName $_.Name.Substring(0, $_.Name.LastIndexOf('-')) -Force}

# 3. Copy and overwrite the files within your GIT folder. (This way you will keep the history)
Copy-Item -Path "$path\*" -Destination $(Split-Path -Path $path -Parent) -Recurse -Force

<#
    When working with GIT you can run the following example:

    git commit -m "Export-DbaInstance @ $((Get-Date).ToString("yyyyMMdd-HHmmss"))"
    git push
#>

#endregion exporting stuff to git

#endregion
