# remove subscriptions
$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'testPub'
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Merge'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'Mergey'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

$sub = @{
    SqlInstance           = 'sql1'
    Database              = 'AdventureWorksLT2022'
    SubscriptionDatabase  = 'AdventureWorksLT2022Snap'
    SubscriberSqlInstance = 'sql2'
    PublicationName       = 'snappy'
    Confirm               = $false
}
Remove-DbaReplSubscription @sub

# remove an article
## we could do it the same way...
# but don't run this...
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'testpub'
        Schema      = 'salesLT'
        Name        = 'customer'
    }
    Remove-DbaReplArticle @article

    # remove an article
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'Mergey'
        Schema      = 'salesLT'
        Name        = 'product'
    }
    Remove-DbaReplArticle @article

    # remove an article
    $article = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Publication = 'snappy'
        Schema      = 'salesLT'
        Name        = 'address'
    }
    Remove-DbaReplArticle @article

# We can also use piping
# using the -WhatIf parameter
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle -WhatIf

# and run it for real
Get-DbaReplArticle -SqlInstance sql1 | Remove-DbaReplArticle

## remove publications
    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'TestPub'
    }
    Remove-DbaReplPublication @pub

    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'Snappy'
        Confirm     = $false
    }
    Remove-DbaReplPublication @pub
    
    $pub = @{
        SqlInstance = 'sql1'
        Database    = 'AdventureWorksLT2022'
        Name        = 'Mergey'
        Confirm     = $false
    }
    Remove-DbaReplPublication @pub

# remove all the publications with piping
Get-DbaReplPublication -SqlInstance sql1 | Remove-DbaReplPublication -Confirm:$false

# disable publishing
Disable-DbaReplPublishing -SqlInstance sql1 -force

<#
Are you sure you want to perform this action?
Performing the operation "Disabling and removing publishing on sql1" on target "sql1".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y
WARNING: [15:20:26][Disable-DbaReplPublishing] Unable to disable replication publishing | Cannot drop server 'sql1' as Distribution Publisher because there are databases enabled for replication on that server.
Changed database context to 'distribution'.
#>

# disable distribution
Disable-DbaReplDistributor -SqlInstance sql1

# check the status
Get-DbaReplServer -SqlInstance sql1