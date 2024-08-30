# How long does it take to run this script?

# you can use your prompt

# lets mess with the prompt
function prompt {
    Write-Host "I am at $PWD" -NoNewline
}

function prompt {
    Write-Host "It is $(Get-Date -Format HH:mm:sss)" -NoNewline
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

# ytou could use the dbatools prompt https://dbatools.io/prompt/
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
