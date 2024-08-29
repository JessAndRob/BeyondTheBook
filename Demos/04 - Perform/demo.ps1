# use t-sql sometimes

# use $null =

# use pwsh

# use parallel

# profiler demos for all of these

# use smo but with the dbachecks magic

# filter left

# remove unnecessary output

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