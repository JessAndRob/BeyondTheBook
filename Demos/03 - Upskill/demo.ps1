# How long does it take to run this script?

# you can use your prompt

# lets mess with the prompt
function prompt {
    Write-Host "I am at $PWD" -NoNewline
}

function prompt {
    Write-Host "It is $(Get-Date -Format HH:mm:sss)  " -NoNewline
}

Start-Sleep -Seconds 3

# wait what? :-)

function Prompt {
    $executionTime = ((Get-History)[-1].EndExecutionTime - (Get-History)[-1].StartExecutionTime).Totalmilliseconds
    $time = [math]::Round($executionTime, 2)
    $promptString = ("$time ms | " + $(Get-Location) + ">")
    Write-Host $promptString -NoNewline -ForegroundColor cyan
    return " "
}

Start-Sleep -Seconds 3

# well thats a bit better

# you could use the dbatools prompt https://dbatools.io/prompt/
# if you have dbatools
function Prompt {
    Write-Host "[" -NoNewline
    Write-Host (Get-Date -Format "HH:mm:ss") -ForegroundColor Gray -NoNewline

    try {
        $history = Get-History -ErrorAction Ignore
        if ($history) {
            Write-Host "][" -NoNewline
            if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type) {
                Write-Host ([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime)) -ForegroundColor Gray -NoNewline
            }
            else {
                Write-Host ($history[-1].EndExecutionTime - $history[-1].StartExecutionTime) -ForegroundColor Gray -NoNewline
            }
        }
    }
    catch { }
    Write-Host "] $($executionContext.SessionState.Path.CurrentLocation.ProviderPath)" -NoNewline
    "> "
}

Start-Sleep -Seconds 3

# You can go the full hog and use oh-my-posh

Load-Profile

Start-Sleep -Seconds 3

# You can use Measure-Command

$Command = { Start-Sleep -Seconds 3 }
$Result = Measure-Command -Expression $Command
$Result.TotalMilliseconds

# the funny thing here is the prompt doesnt show the result you expect becuase it is the last execution it shows!!

# Thats for a single command but in a script that doesnt really help you !

Install-PSResource Profiler

Get-Command -Module Profiler

Trace-Script -ScriptBlock { Start-Sleep -Seconds 3 }

# what you should do is assign top a variable - but because I didnt it helped me

$trace = Get-LatestTrace

$trace
$trace.Top50HitCount

# what does profiler do?
$trace.Events | Format-Table -AutoSize

# lets do something more complicated or do we use this to do the perf stuff



# maybe read in the file list from the backup demo from the 01 session?



# Always use $null -eq never use -eq $null

$thingIamsearchthrough = 1, 2, 3, 4, 5, 6, "seven", "eight", $null, 9, 10

#how many?

$thingIamsearchthrough.Count

# loop through them
foreach ($thing in $thingIamsearchthrough) {
    $thing
}

# Do something
foreach ($thing in $thingIamsearchthrough) {
    if ($thing -eq $null) {
        Write-Output "OH NO - $($Thing) is NULL"
    } else {
        Write-Output "Phew - $($thing) is not null"
    }
}
# Do something
foreach ($thing in $thingIamsearchthrough) {
    if ( $null -eq $thing) {
        Write-Output "OH NO - $($Thing) is NULL"
    } else {
        Write-Output "Phew - $($thing) is not null"
    }
}

$value = $null

if ( $value -eq $null )
{
    'The array is $null'
}
if ( $value -ne $null )
{
    'The array is not $null'
}

$value = @( $null )
if ( $value -eq $null )
{
    'The array is $null'
}
if ( $value -ne $null )
{
    'The array is not $null'
}

function Get-True  {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Magic
    )
    $Magic -eq $null -and  $Magic -ne $null
  }

  Describe 'Get-True' {
    It 'Returns $true' {
      $MagicSauce = $( <# what needs to go here...? #> )
      Get-True -Magic $MagicSauce | Should BeExactly $true
    }
  }


$whatamI = Invoke-DbaQuery -SqlInstance sql1 -Database master -Query "SELECT NULL"

$whatamI

$whatamI.Column1

$whatamI.Column1 |gm

$whatamI.Column1.Gettype().name

$whatamI.Column1 -eq $null

# oh yeah, we just did that

$null -eq $whatamI.Column1


# ah

[System.DBNull]::Value -eq $whatamI.Column1
$whatamI.Column1 -eq [System.DBNull]::Value




# 1) check for += assignments in PowerShell arrays and replace with .net collections
# 2) look for bad runtime complexity - hashtable / keys > searching by where-object etc.

# Using Hashsets for filtering unique; get rid of curly braces in Where-Object; using switch statement for filereading if no classes are allowed


#region dbatools upskills

#region truncate all the tables in a database

# Also - change all the whatevers in an object

$SqlInstance = 'dbatools1'
$database = 'pubs'
$tempFolder = './export/'

#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# TWO DEMOS FOR THE PRICE OF ONE!!

# First things first - lets make a copy of this database to test on
Copy-DbaDatabase -Source $SqlInstance -Database $database -Destination $SqlInstance -NewName 'pubsV2' -BackupRestore -SharedPath /Shared
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Alright back to the real demo
$database = 'pubsV2'
# we're going to use SMO objects so let's connect to the instance
$svr = Connect-DbaInstance -SqlInstance $SqlInstance

# Truncate the tables
$svr.databases[$database].Tables | ForEach-Object { $_.TruncateData() }

# but why?
Get-Error

## Collect up the objects we need to drop and recreate
$objects = @()
$objects += Get-DbaDbForeignKey -SqlInstance $svr -Database $database
$objects += Get-DbaDbView -SqlInstance $svr -Database $database -ExcludeSystemView

## Script out the create statements for objects
$createOptions = New-DbaScriptingOption
$createOptions.Permissions = $true
$createOptions.ScriptBatchTerminator = $true
$createOptions.AnsiFile = $true
$objects | Export-DbaScript -FilePath ('{0}\CreateObjects.Sql' -f $tempFolder) -ScriptingOptionsObject $createOptions

## Script out the drop statements for objects
$dropOptions = New-DbaScriptingOption
$dropOptions.ScriptDrops = $true
$objects| Export-DbaScript -FilePath ('{0}\DropObjects.Sql' -f $tempFolder) -ScriptingOptionsObject $dropOptions

# Run the drop scripts
Invoke-DbaQuery -SqlInstance $svr -Database $database -File ('{0}\DropObjects.Sql' -f $tempFolder)

# Truncate the tables
$svr.databases[$database].Tables | ForEach-Object { $_.TruncateData()}

# Run the create scripts
Invoke-DbaQuery -SqlInstance $svr -Database $database -File ('{0}\CreateObjects.Sql' -f $tempFolder)

# Clear up the script files
Remove-Item ('{0}\DropObjects.Sql' -f $tempFolder), ('{0}\CreateObjects.Sql' -f $tempFolder)

#endregion truncate

#region find objects owned by a user

# If you want to read more about a real use case, check this blog post:
# https://claudioessilva.eu/2020/09/03/When-one-of-your-DBA-colleagues-leaves-the-company-what-is-your-checklist/

# Normally you would like to search for some AD account
$pattern = 'sqladmin'

#Find objects owned by a specific user
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern

# Format as table
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern | Format-Table

# Output as Console GridView
Find-DbaUserObject -SqlInstance dbatools1 -Pattern $pattern | Out-ConsoleGridView


<#
What will it search?
    - Database Owner
    - Agent Job Owner
    - Used in Credential
    - Used in Proxy
    - SQL Agent Steps using a Proxy
    - Endpoints
    - Server Roles
    - Database Schemas
    - Database Roles
    - Database Assembles
    - Database Synonyms
#>
#endregion find

#region execute a folder of scripts (part one - we will do this better later)


$folderPath = './export/'
$SqlInstance = 'dbatools1'
$sourceDatabase = 'Pubs'
$destinationDatabase = 'PubsV2'

######################################
# Setup - create a folder of scripts #
######################################

# create the output path if it doesn't exist
if (!(Test-Path $folderPath)) {
    $null = New-Item -Path $folderPath -ItemType Directory
}

# Export create statements for tables
# Using a foreach loop so we can control the name of each file separately
$so = New-DbaScriptingOption
$so.ConvertUserDefinedDataTypesToBaseType = $true

Get-DbaDbTable -SqlInstance $SqlInstance -Database $sourceDatabase |
ForEach-Object -PipelineVariable obj -Process { $_ } |
ForEach-Object { Export-DbaScript -InputObject $obj -ScriptingOptionsObject $so -FilePath ('{0}\{1}_{2}.sql' -f $folderPath, $obj.Schema, $obj.Name) }


# See how many sql files we have to execute
Get-ChildItem $folderPath *.sql | Measure-Object | Select-Object Count
<#
Count
-----
11
#>

# Create a new empty database
$splatCreate = @{
    SqlInstance = $SqlInstance
    Name        = $destinationDatabase
}
New-DbaDatabase @splatCreate

###############################
# Execute a folder of scripts #
###############################

(Get-ChildItem $folderPath *.sql).Foreach{
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $destinationDatabase -File $psitem.FullName
}

# clean up files
Get-ChildItem $folderPath *.sql | Remove-Item

#endregion execute

#region users report

#TODO - maybe add Robs Notebooks demo for this and include that ?
$excludeDatabase = "myDB", "myDB2"
$excludeLogin = "renamedSA"
$excludeLoginFilter = "NT *", "##*"
$SQLInstance = "dbatools1", "dbatools2"

# To be used on Export-Excel command
$excelFilepath = "./export/$($SQLInstance -replace ',', '')_$((Get-Date).ToFileTime()).xlsx"
$freezeTopRow = $true
$tableStyle = "Medium6"


#Region Get data
# Get all instance logins
$Logins = Get-DbaLogin -SqlInstance $SQLInstance -ExcludeLogin $excludeLogin -ExcludeFilter $excludeLoginFilter

# Get all server roles and its members
$instanceRoleMembers = Get-DbaServerRoleMember -SqlInstance $SQLInstance -Login $Logins.Name

# Get all database roles and its members
$dbRoleMembers = Get-DbaDbRoleMember -SqlInstance $SQLInstance -ExcludeDatabase $excludeDatabase | Where-Object UserName -in $logins.Name
#EndRegion


# Remove the report file if exists
Remove-Item -Path $excelFilepath -Force -ErrorAction SilentlyContinue


#Export result to excel. It uses ImportExcel PowerShell Module from Doug Finke

#Region Export Data to Excel
# Export data to Excel
## Export Logins
$excelLoginSplatting = @{
    Path = $excelFilepath
    WorkSheetname = "Logins"
    TableName = "Logins"
    FreezeTopRow = $freezeTopRow
    TableStyle = $tableStyle
}
$Logins | Select-Object "ComputerName", "InstanceName", "SqlInstance", "Name", "LoginType", "CreateDate", "LastLogin", "HasAccess", "IsLocked", "IsDisabled" | Export-Excel @excelLoginSplatting

## Export instance roles and its members
$excelinstanceRoleMembersOutput = @{
    Path = $excelFilepath
    WorkSheetname = "InstanceLevel"
    TableName = "InstanceLevel"
    TableStyle = $tableStyle
    FreezeTopRow = $freezeTopRow
}
$instanceRoleMembers | Export-Excel @excelinstanceRoleMembersOutput

## Export database roles and its members
$exceldbRoleMembersOutput = @{
    Path = $excelFilepath
    WorkSheetname = "DatabaseLevel"
    TableName = "DatabaseLevel"
    TableStyle = $tableStyle
    FreezeTopRow = $freezeTopRow
}
$excel = $dbRoleMembers | Export-Excel @exceldbRoleMembersOutput -PassThru


# Add some RED background to sysadmin entries
$rulesparam = @{
    Range   = $excel.Workbook.Worksheets["InstanceLevel"].Dimension.Address
    WorkSheet = $excel.Workbook.Worksheets["InstanceLevel"]
    RuleType  = "Expression"
    ConditionValue = 'NOT(ISERROR(FIND("sysadmin",$D1)))'
    BackgroundColor = "LightPink"
    Bold = $true
}

Add-ConditionalFormatting @rulesparam
Close-ExcelPackage -ExcelPackage $excel #-Show

#EndRegion

#endregion users report

#region Snapshots

#TODO - Jess explain to Rob what this is doing!!

#endregion

#region copy table data

# Set some variables
$sourceDB = "Northwind"
$destinationDB = "EmptyNorthwind"
$table = "[dbo].[Order Details]"

# Create empty database on destination instance
New-DbaDatabase -SqlInstance dbatools2 -Name $destinationDB

# Check table's content on source
Invoke-DbaQuery -SqlInstance dbatools1 -Database $sourceDB -Query "SELECT TOP 10 * FROM $table" | Format-Table

# Prove the destination table is does not exists
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT TOP 10 * FROM $table" | Format-Table


<#
Copy data
    Note: Table does not exist so it will be created. However without PK, FK, UQ, (non)Clustered indexes..etc.
    If you need to keep all the objects take a look at the following blog post to understand how you can create
the object with same structure/properties before copying the data.
        “UPS…I HAVE DELETED SOME DATA. CAN YOU PUT IT BACK?” – DBATOOLS FOR THE RESCUE
        (https://claudioessilva.eu/2019/05/17/Ups...I-have-deleted-some-data.-Can-you-put-it-back-dbatools-for-the-rescue/)
#>

# Copy all data within "dbo.Order Details" to another instance
$copySplat = @{
    SqlInstance = "dbatools1"
    Destination = "dbatools2"
    Database = $sourceDB
    DestinationDatabase = $destinationDB
    Table = $table
    AutoCreateTable = $true
    BatchSize = 1000
}
Copy-DbaDbTableData @copySplat

# Prove that now, we have data on the destination table
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT TOP 10 * FROM $table" | Format-Table



# Another example

# Copy data based on a query

# Copy specific data (see query parameter) from [dbo].[Order Details] to [dbo].[CopyOf_Order Details]
$copySplat = @{
    SqlInstance = "dbatools1"
    Destination = "dbatools2"
    Database = $sourceDB
    DestinationDatabase = $destinationDB
    Table = $table
    DestinationTable = "[dbo].[CopyOf_Order Details]"
    AutoCreateTable = $true
    BatchSize = 1000
    Query = "SELECT * FROM $sourceDB.$table WHERE Quantity > 70 "
}
Copy-DbaDbTableData @copySplat


#Confirm that data is there
Invoke-DbaQuery -SqlInstance dbatools2 -Database $destinationDB -Query "SELECT * FROM [dbo].[CopyOf_Order Details]" | Format-Table

#endregion

#region Azure SQL Database and dbatools

$instance = ''
$database = ''

$Sql = Connect-DbaInstance -SqlInstance $instance

$Sql

$query = "SELECT DB_NAME() AS DatabaseName"

Invoke-DbaQuery -SqlInstance $Sql -Database $database -Query $query

# HUH?

# When you connect to an Azure SQL Database, you need to specify the database name.

$Sql = Connect-DbaInstance -SqlInstance $Sql -Database $database

Invoke-DbaQuery -SqlInstance $Sql -Database $database -Query $query
#endregion Azure

#region deploy tools like WHoIsActive

# Deploy sp_whoIsActive across instances
# NOTE: I wrote about it in my blog post: New version of sp_WhoIsActive (v11.20) is available – Deployed on 123 instances in less than 1 minute
# https://claudioessilva.eu/2017/12/05/new-version-of-sp_whoisactive-v11-20-is-available-deployed-on-123-instances-in-less-than-1-minute/

# Set variables
$databaseToDeploy = "master"

# Deploy the stored procedure on a list of instances

# If you have internet access
Install-DbaWhoIsActive -SqlInstance dbatools1, dbatools2 -Database $databaseToDeploy -Confirm:$false


#ToDo: Check file permissions:
# WARNING: [14:32:19][Install-DbaWhoIsActive] Failed to update local cached copy | You do not have sufficient access rights to perform this operation or the item is hidden, system, or read only.
# we have to remove this folder during the demo - something permissions related ¯\_(ツ)_/¯
Remove-Item  '/root/.local/share/PowerShell/dbatools/WhoIsActive' -Recurse -Force

# If you have a file version of it (or without Internet access)
$deploySplat = @{
    SqlInstance = 'dbatools1', 'dbatools2'
    Database = $databaseToDeploy
    LocalFile = "./demos/3/sp_WhoIsActive.sql"
}
# Without internet access but with a version saved on a local file
Install-DbaWhoIsActive @deploySplat

# You can use the dbatools Invoke-DbaWhoIsActive command to run the stored procedure
Invoke-DbaWhoIsActive -SqlInstance dbatools1 -ShowOwnSpid

#endregion deploy

#endregion upskills