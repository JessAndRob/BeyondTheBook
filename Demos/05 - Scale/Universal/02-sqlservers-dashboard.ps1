$Pages = @()
$Pages += New-UDPage -Name 'Home' -Content {
    New-UDTypography -Text 'Home'

} -Icon home
$Pages += New-UDPage -Name 'SQLInstances' -Content {
    New-UDTypography -Text 'SQL Instances'

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {

            $instances = Invoke-RestMethod -Uri http://localhost:5000/SqlInstances/GetSqlInstances

            $Columns = @(
                New-UDTableColumn -Property SqlInstance -Title "SQL Instance" -render {New-UDLink -Text $EventData.SqlInstance -OnClick {
                    $page:instance = $EventData.SqlInstance
                    Invoke-UDRedirect -Url '/databases'
                } }
                New-UDTableColumn -Property VersionString -Title "Version"
                New-UDTableColumn -Property EngineEdition -Title "Engine Edition"
                New-UDTableColumn -Property Edition -Title "Edition"
                New-UDTableColumn -Property HostDistribution -Title "Host Distribution"
            )
            New-UDTable -Data $instances -Columns $Columns
        }
    }
} -Icon "fas fa-server"
$Pages += New-UDPage -Name 'Databases' -url '/databases' -Content {

    $instances = Invoke-RestMethod -Uri http://localhost:5000/SqlInstances/GetSqlInstances

    New-UDDynamic -Id 'databasesTitle' -Content {
        if (-not $page:instance) {
            New-UDTypography -Text ('Databases') -Variant "h3" 
        } else {
            New-UDTypography -Text ('Databases for {0}' -f $page:instance) -Variant "h3" 
        }
    }
    #New-UDStack -Content {
    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDTypography -Text 'Select an instance to view the databases for it'
        }
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDSelect -Option {
                $instances.SqlInstance.foreach{
                    New-UDSelectOption -Name $_ -Value $_
                }
            } -OnChange {
                Show-UDToast -Message $EventData
                $page:instance = $EventData
                Sync-UDElement -Id 'databases'
                Sync-UDElement -Id 'databasesTitle'
            }
        }
    }
    #} -Direction 'column'

    New-UDDynamic -Id 'databases' -Content {
        if ($page:instance) {
            $body = [PSCustomObject]@{ SqlInstance = $page:instance } | ConvertTo-Json
            $Data = Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases" -Method Get -Body $body -ContentType 'application/json'

            $Columns = @(
                New-UDTableColumn -Property SqlInstance -Title "SQL Instance"
                New-UDTableColumn -Property Name -Title "Name"
                New-UDTableColumn -Property Status -Title "Status"
                New-UDTableColumn -Property Compatibility -Title "Compatibility"
                New-UDTableColumn -Property LastFullBackup -Title "Last Full Backup"
                New-UDTableColumn -Property LastDiffBackup -Title "Last Diff Backup"
                New-UDTableColumn -Property LastLogBackup -Title "Last Log Backup"
                New-UDTableColumn -Property Backup -Render {
                    New-UDButton -Text "Backup" -OnClick {
                        Show-UDToast -Message "Starting backup for $($EventData.Name)"
                        $body = ("`"{0}`":`"{1}`",`"{2}`":`"{3}`"" -f 'SqlInstance', $EventData.SqlInstance, 'Database', $EventData.Name)
                        $backup = Invoke-RestMethod -Uri "http://localhost:5000/Databases/Backup" -Method Post -Body "{ $body }" -ContentType 'application/json'
                        if($backup.BackupComplete) {
                            Show-UDToast -Duration 3000 -Icon "fas fa-copy" -Message "Backup completed successfully for $($EventData.Name) at $($backup.End)."
                        } else {
                            Show-UDToast -Duration 3000 -Icon "fas fa-times" -Message "Backup failed!"
                        }
                        Sync-UDElement -Id 'databases'
                    }
                }
            )
            New-UDTable -Data $Data -Columns $Columns -ShowPagination -PageSize 10
        }
    }
} -Icon "fas fa-database"

New-UDApp -Pages $Pages -Title 'SQL Instance Dashboard'

