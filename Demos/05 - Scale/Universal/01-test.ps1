# we need a module and then to install PowerShell Universla
# as admin
Install-Module Universal
Install-PSUServer



#region /servers endpoint
# Enter your script to process requests.

Connect-DbaInstance -SqlInstance sql1,sql2,sql3 | Select-Object SqlInstance,VersionString,EngineEdition,Edition,HostDistribution
#endregion

#region /databases endpoint
$sqlinstance = 'sql1'

$null = Set-DbatoolsInsecureConnection

Get-DbaDatabase -SqlInstance $sqlinstance | Select-Object SqlInstance,Name,Status,Compatibility,LastFullBackup,LastDiffBackup,LastLogBackup
#endregion

