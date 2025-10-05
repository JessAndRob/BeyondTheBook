## This is a demo to setup log shipping from one source to 2 destinations, with the goal of then joining them to an AG

# get a database


$source = 'sql3'
$databaseName = 'AdventureWorks2017'
$secondNode = 'sql1'
$thirdNode = 'sql2'
$sharedPath = '\\sql1\Backups\'
$agName = 'Ag1'

Mkdir \\$source\c$\temp\

Invoke-WebRequest -Uri https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak -OutFile \\$source\c$\temp\AdventureWorks2017.bak
Restore-DbaDatabase -SqlInstance $source -Path C:\temp\AdventureWorks2017.bak -UseDestinationDefaultDirectories
Set-DbaDbRecoveryModel -SqlInstance $source -Database $databaseName -RecoveryModel Full

# Full backup
$backupParams = @{
    SqlInstance = $source
    Database = $databaseName
    Type = 'Full'
    CopyOnly = $false
    CompressBackup = $true
    Path = $sharedPath
    OutVariable = 'fullBackup'
}
Backup-DbaDatabase @backupParams

## restore norecovery to log shipping destinations
$restoreParams = @{
    Path = $fullBackup.BackupPath
    NoRecovery = $true
    UseDestinationDefaultDirectories = $true
}
$secondNode, $thirdNode | ForEach-Object { 
    Restore-DbaDatabase -SqlInstance $_ @restoreParams
} 

# setup
# make sure file paths exist
$params = @{
    SourceSqlInstance = $source
    DestinationSqlInstance = $secondNode, $thirdNode
    Database = 'AdventureWorks2017'
    SharedPath = '\\sql1\Backups\sql3'
    CopyDestinationFolder = '\\sql1\Backups\sql2'
    CompressBackup = $true
    GenerateFullBackup = $false  # do we want this
    BackupScheduleStartTime = '000000'
    CopyScheduleStartTime = '000500'
    RestoreScheduleStartTime = '001000'
    Force = $true
}
Invoke-DbaDbLogShipping @params

## cutover

# disable jobs (just log shipping here - are there other jobs to disable?)
Get-DbaAgentJob -SqlInstance $secondNode,$thirdNode,$source -Category 'log shipping' | Set-DbaAgentJob -Disabled

# run log shipping jobs once more 
#backup
Start-DbaAgentJob -SqlInstance $source -Job ('LSBackup_{0}' -f $databaseName) -Wait

# copy
Start-DbaAgentJob -SqlInstance $secondNode -Job ('LSCopy_{0}_{1}' -f $source, $databaseName) -Wait
Start-DbaAgentJob -SqlInstance $thirdNode -Job ('LSCopy_{0}_{1}' -f $source, $databaseName) -Wait

# restore
Start-DbaAgentJob -SqlInstance $secondNode -Job ('LSRestore_{0}_{1}' -f $source, $databaseName) -Wait
Start-DbaAgentJob -SqlInstance $thirdNode -Job ('LSRestore_{0}_{1}' -f $source, $databaseName) -Wait

# drop log shipping configuration - but keep the secondary databases
$params = @{
    PrimarySqlInstance = $source
    SecondarySqlInstance = $secondNode
    Database = $databaseName
    RemoveSecondaryDatabase = $false
}
Remove-DbaDbLogShipping @params

## clean up jobs from thirdNode
Get-DbaAgentJob -SqlInstance $thirdNode -Category 'Log Shipping' | Remove-DbaAgentJob -Confirm:$false

# final log backup from source
$backupParams = @{
    SqlInstance = $source
    Database = $databaseName
    Path = '\\sql1\Backups\sql3' #TODO: CHANGE PATH
    Type = 'Log'
    CompressBackup = $true
    OutVariable = 'trnBackup'
}
Backup-DbaDatabase @backupParams

# take source database offline
Set-DbaDbState -SqlInstance $source -Database $databaseName -Offline -Force

# restore that log file with continue (can nodes get here? otherwise we need to move it to their folder)
$restoreParams = @{
    SqlInstance = $secondNode
    DatabaseName = $databaseName
    Path = $trnBackup.Path
    Continue = $true
    NoRecovery = $false # bring online on node 2
}
Restore-DbaDatabase @restoreParams

$restoreParams = @{
    SqlInstance = $thirdNode
    DatabaseName = $databaseName
    Path = $trnBackup.Path
    Continue = $true
    NoRecovery = $true # leave it in norecovery on node 3 for AG join
}
Restore-DbaDatabase @restoreParams

# go add to AG in GUI
Add-DbaAgDatabase -SqlInstance $secondNode -Database $databaseName -AvailabilityGroup $agName -SeedingMode Manual