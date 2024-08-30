# use t-sql sometimes

# use $null =

# use pwsh

# use parallel

# profiler demos for all of these

# use smo but with the dbachecks magic

# filter left

# remove unnecessary output

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

## Lets create some files

$filecontent = 0..100 | ForEach-Object { Invoke-RestMethod -Uri https://loripsum.net/api/10/short/headers }

$directory = "C:\temp\perf"
if (-not (Test-Path $directory)) {
    New-Item -Path $directory -ItemType Directory
} else {
    Get-ChildItem -Path $directory | Remove-Item -Force
}
0..10 | ForEach-Object {
    $loop = $_
    0..100 | ForEach-Object {
        $filename = "{0}\file{1}{2}.txt" -f $directory, $loop, $_
        $filecontent[$_] | Set-Content -Path $filename
    }
}

Get-ChildItem -Path $directory

# lets do some file content searching

# Get-Content can read a file contents into memory,

Get-Content -Path "$($directory)\file0.txt" | Select-String "quidem"

# but it is not the best way to search for a string in a bunch of files.

$GetContent = Trace-Script -ScriptBlock { Get-ChildItem $directory |
    Get-Content |
    Select-String "quidem"
}
$SelectString = Trace-Script -ScriptBlock { Get-ChildItem $directory | Select-String "quidem" }

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

                