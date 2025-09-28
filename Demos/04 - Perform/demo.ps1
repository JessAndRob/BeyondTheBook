<#
from Jakub - The top 3 things that Profiler will show you. :) Typically += in a loop (before the fix), reading files without -Raw, and other IO you can do once and cache.
#>

<#
Thats a getting the right answer rather than a perf increase but yes
To ensure that PowerShell performs comparisons correctly, the $null element should be on the left side of the operator.

There are multiple reasons why this occurs:

$null is a scalar value. When the value on the left side of an operator is a scalar, comparison operators return a Boolean value. When the value is a collection, the comparison operators return any matching values or an empty array if there are no matches in the collection.
PowerShell performs type casting left to right, resulting in incorrect comparisons when $null is cast to other scalar types.
The only way to reliably check if a value is $null is to place $null on the left side of the operator so that a scalar comparison is performed.
#>

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

## Lets create some files

$filecontent = 0..100 | ForEach-Object { Invoke-RestMethod -Uri https://baconipsum.com/api/?type=meat-and-filler }

if ($IsWindows){
$directory = "C:\temp\perf"
}elseif ($IsLinux){
$directory = "/tmp/perf"
}

if (-not (Test-Path $directory)) {
    New-Item -Path $directory -ItemType Directory
} else {
    Get-ChildItem -Path $directory | Remove-Item -Force
}
0..10 | ForEach-Object {
    $loop = $_
    0..100 | ForEach-Object {
        $filename = "{0}{3}file{1}{2}.txt" -f $directory, $loop, $_,[IO.Path]::DirectorySeparatorChar
        $filecontent[$_] | Set-Content -Path $filename
    }
}

Get-ChildItem -Path $directory

# lets do some file content searching

# Get-Content can read a file contents into memory,

Get-Content -Path "$($directory)$([IO.Path]::DirectorySeparatorChar)file00.txt" | Select-String "bacon"

# but it is not the best way to search for a string in a bunch of files.

$GetContent = Trace-Script -ScriptBlock { Get-ChildItem $directory |
    Get-Content |
    Select-String "bacon"
}
$SelectString = Trace-Script -ScriptBlock { Get-ChildItem $directory | Select-String "bacon" }

$GetContent.TotalDuration.Milliseconds

$SelectString.TotalDuration.Milliseconds

##################

$plusequals = Trace-Script -ScriptBlock {
    ForEach ($file in (Get-ChildItem $directory)) {
        $collection += $file | Select-String "Result"
    }
    $collection
}

$arrayList = Trace-Script -ScriptBlock {
    $collection = New-Object System.Collections.ArrayList
    $null = Get-ChildItem $directory | ForEach-Object {
        $collection.Add($_)
    }
}

$plusequals.TotalDuration.Milliseconds
$arrayList.TotalDuration.Milliseconds


$dbaInstance = Connect-DbaInstance -SqlInstance sql1

$instance = New-Object Microsoft.SqlServer.Management.Smo.Server 'sql1'

$dbaInstance.gettype()
$Instance.gettype()

#clear out the default initialised fields
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Information], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $false)
$Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)

$DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database]) #  I think we need to re-initialise here


$DatabaseInitFields.Add("Name ") | Out-Null # so we can check if its accessible
$DatabaseInitFields.Add("IsSystemObject ") | Out-Null # so we can check if its accessible

$dbacommand = Trace-Script -ScriptBlock {
    Get-DbaDatabase -SqlInstance sql1
}
$dbaquerycommand = Trace-Script -ScriptBlock {
    Invoke-DbaQuery -SqlInstance sql1 -Database master -Query "SELECT name FROM sys.databases"
}
$smocommand = Trace-Script -ScriptBlock {
    $instance.Databases.Name
}

$dbacommand.TotalDuration.TotalMilliseconds
$dbaquerycommand.TotalDuration.TotalMilliseconds
$smocommand.TotalDuration.TotalMilliseconds

$instancesql3 = New-Object Microsoft.SqlServer.Management.Smo.Server 'sql3'


## TODO - this could be the start of scale


#clear out the default initialised fields
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Server], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Login], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Agent.Job], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.StoredProcedure], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Information], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Settings], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.LogFile], $false)
$Instancesql3.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.DataFile], $false)

$DatabaseInitFields = $Instancesql3.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database]) #  I think we need to re-initialise here


$DatabaseInitFields.Add("Name ") | Out-Null # so we can check if its accessible
$DatabaseInitFields.Add("IsSystemObject ") | Out-Null # so we can check if its accessible



$dbacommandsql3 = Trace-Script -ScriptBlock {
    Get-DbaDatabase -SqlInstance sql3
}
$dbaquerycommandsql3 = Trace-Script -ScriptBlock {
    Invoke-DbaQuery -SqlInstance sql3 -Database master -Query "SELECT name FROM sys.databases"
}
$smocommandsql3 = Trace-Script -ScriptBlock {
    $instancesql3.Databases.Name
}
$normalinstancesql3 = New-Object Microsoft.SqlServer.Management.Smo.Server 'sql3'
$normalsmocommandsql3 = Trace-Script -ScriptBlock {
    $normalinstancesql3.Databases.Name
}

$dbacommandsql3.TotalDuration.TotalMilliseconds
$dbaquerycommandsql3.TotalDuration.TotalMilliseconds
$normalsmocommandsql3.TotalDuration.TotalMilliseconds
$smocommandsql3.TotalDuration.TotalMilliseconds



                #Test-DbaMaxDop needs these because it checks every database as well
                $DatabaseInitFields.Add("IsAccessible") | Out-Null # so we can check if its accessible
                $DatabaseInitFields.Add("IsSystemObject ") | Out-Null # so we can check if its accessible
                $DatabaseInitFields.Add("MaxDop ") | Out-Null # so we can check if its accessible
                $DatabaseInitFields.Add("Name ") | Out-Null # so we can check if its accessible
                $Instance.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], $DatabaseInitFields)
                $DatabaseInitFields = $Instance.GetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database]) #  I think we need to re-initialise here

# use t-sql sometimes

# use $null =

# use pwsh

# use parallel

# profiler demos for all of these

# use smo but with the dbachecks magic

# filter left

# remove unnecessary output