$Pages = @()
$Pages += New-UDPage -Name 'SQLInstances' -Content {
    New-UDTypography -Text 'SQL Instances'

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {

            $Data = Invoke-RestMethod -Uri http://localhost:5000/SqlInstances/GetSqlInstances

            $Columns = @(
                New-UDTableColumn -Property SqlInstance -Title "SQL Instance" -render {New-UDLink -Text $EventData.SqlInstance -Url "../db"}
                New-UDTableColumn -Property VersionString -Title "Version"
                New-UDTableColumn -Property EngineEdition -Title "Engine Edition"
                New-UDTableColumn -Property Edition -Title "Edition"
                New-UDTableColumn -Property HostDistribution -Title "Host Distribution"
            )
            New-UDTable -Data $Data -Columns $Columns
        }
    }
}
$Pages += New-UDPage -Name 'Databases' -url '/db' -Content {
    New-UDTypography -Text 'Databases'

    $Data = Invoke-RestMethod -Uri "http://localhost:5000/Databases/GetDatabases" -Method Get -Body '{"sqlinstance":"sql1"}' -ContentType 'application/json'

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
                        Invoke-RestMethod -Uri "http://localhost:5000/Databases/Backup" -Method Post -Body "{ $body }" -ContentType 'application/json'
                    }
                }
            )
            New-UDTable -Data $Data -Columns $Columns

}
New-UDApp -Pages $Pages -Title 'SQL Instance Dashboard'

