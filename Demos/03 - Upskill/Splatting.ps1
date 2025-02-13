###############
## Splatting ##
###############

# Splatting is a way to pass a collection of parameter values to a command as a single unit.

# This is useful when you have a lot of parameters to pass in, or you want to pass in a collection of parameters that you've already defined.

## I asked a couple of AI tools to find me the dbatools command with the 
# most parameters - we got there in the end!

#region get command with most parameters
    # Import the dbatools module if it's not already loaded
    Import-Module dbatools

    # Get a list of all dbatools commands
    $commands = Get-Command -Module dbatools

    # Initialize variables to track the command with the most parameters
    $maxParams = 0
    $commandWithMostParams = $null

    # Iterate over each command to count the parameters
    foreach ($command in $commands) {
        $paramCount = (Get-Command $command.Name).Parameters.Count
        if ($paramCount -gt $maxParams) {
            $maxParams = $paramCount
            $commandWithMostParams = $command
        }
    }

    # Output the command with the most parameters and the count
    $commandWithMostParams.Name
    $maxParams

    #region get command with most parameters - Jess code
        # Import the dbatools module if it's not already loaded
        Import-Module dbatools
    
        # Get a list of all dbatools commands
        $commands = Get-Command -Module dbatools
    
        # Initialize variables to track the command with the most parameters
        $maxParams = 0
        $commandWithMostParams = $null
    
        $paramcount = @()
        # Iterate over each command to count the parameters
        foreach ($command in $commands) {
            $paramCount += [PSCustomObject]@{
                CommandName = $command.Name
                ParameterCount = [int]((Get-Command $command.Name).Parameters.Count)
            }
        }
        $paramcount | Sort-Object -Property ParameterCount -Descending | Select-Object -First 10
    
        # Output the command with the most parameters and the count
        $commandWithMostParams.Name
        $maxParams
    #endregion
#endregion


##TODO: look at log shipping on sql1\sql2

## Lets take a full backup of the pubs database using the Backup-DbaDatabase command
Backup-DbaDatabase -SqlInstance mssql1 -SqlCredential $cred -Database pubs -BlockSize 16KB -BufferCount 7 -MaxTransferSize 1MB -CheckSum -CopyOnly -CompressBackup -Path '/shared' -Type Full -FileCount 7 -Verify -Description 'A full backup taken of the pubs database by Jess and Rob at SQL Konf.'

## We can use splatting to make this easier to read
$backupParams = @{
    SqlInstance = 'sql1'
    SqlCredential = $cred
    Database = 'msdb'
    BlockSize = '16KB'
    BufferCount = 7
    MaxTransferSize = '1MB'
    CheckSum = $true
    CopyOnly = $true
    CompressBackup = $true
    Path = 'C:\temp'
    Type = 'Full'
    FileCount = 7
    Verify = $true
    Description = 'A full backup taken of the pubs database by Jess and Rob at SQL Konf.'
}
Backup-DbaDatabase @backupParams
