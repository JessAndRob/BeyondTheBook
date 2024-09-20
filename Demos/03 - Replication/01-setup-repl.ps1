# Import the dev module
#Import-Module C:\Github\jpomfret\dbatools\dbatools.psd1 -Force
Import-Module dbatools

# Connect test
Connect-DbaInstance -SqlInstance sql1, sql2

# smo defaults
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false
Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true

# Connect test
Connect-DbaInstance -SqlInstance sql1, sql2

# gets

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql1

# view publications
Get-DbaReplPublication -SqlInstance sql1

# view articles
Get-DbaReplArticle -SqlInstance sql1

# get subscriptions
Get-DbaReplSubscription -SqlInstance sql1



# enable distribution
Enable-DbaReplDistributor -SqlInstance sql1

# enable publishing
Enable-DbaReplPublishing -SqlInstance sql1

# Get the distributor
Get-DbaReplDistributor -SqlInstance sql1

# add a transactional publication
$pub = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Name        = 'testPub'
    Type        = 'Transactional'
}
New-DbaReplPublication @pub

# view publications
Get-DbaReplPublication -SqlInstance sql1

$testPub = Get-DbaReplPublication -SqlInstance sql1 -Name testPub
$testPub | Get-Member
$testPub | Format-List *

# add an article to our publication
$article = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorksLT2022'
    Publication = 'testpub'
    Schema      = 'salesLT'
    Name        = 'customer'
    Filter      = "lastname = 'gates'"
}
Add-DbaReplArticle @article

# view articles
Get-DbaReplArticle -SqlInstance sql1

# we can't see the filter - but there are more properties available
Get-DbaReplArticle -SqlInstance sql1 -Publication testPub | 
Select-Object SqlInstance, DatabaseName, PublicationName, Name, SourceObjectOwner, SourceObjectName, FilterClause

# and view publications
Get-DbaReplPublication -SqlInstance sql1

# and view articles from publications - magic of objects
(Get-DbaReplPublication -SqlInstance sql1 -Name snappy).Articles

# add a subscription
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    PublicationName       = 'testpub'
    Type                  = 'Push'
}
New-DbaReplSubscription @sub

# view subscriptions
Get-DbaReplSubscription -SqlInstance sql1

#View publications again
Get-DbaReplPublication -SqlInstance sql1

# start snapshot agent
Get-DbaAgentJob -SqlInstance sql1 -Category repl-snapshot | Start-DbaAgentJob
