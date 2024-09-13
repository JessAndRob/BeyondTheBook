
# Enter your script to process requests.
$null = Set-DbatoolsInsecureConnection
Connect-DbaInstance -SqlInstance sql1,sql2,sql3 | select SqlInstance,VersionString,EngineEdition,Edition,HostDistribution
