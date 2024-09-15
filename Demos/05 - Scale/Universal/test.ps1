$Pages = @()
$Pages += New-UDPage -Name 'SQLInstances' -Content {
    New-UDTypography -Text 'SQL Instances'

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDDataGrid -LoadRows {
                $Data = Invoke-RestMethod -Uri http://localhost:5000/SQLInstances/GetSqlInstances 
                $Data | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
                New-UDDataGridColumn -Field SqlInstance -render { 
                    New-UDLink -Text $EventData.SqlInstance -Url "/server?instance=$($EventData.SqlInstance)"
                }
                New-UDDataGridColumn -Field VersionString
                New-UDDataGridColumn -Field EngineEdition
                New-UDDataGridColumn -Field Edition
                New-UDDataGridColumn -Field HostDistribution
                New-UDDataGridColumn -Field ButtonTest -Render {
                    New-UDButton -Text "Test" -OnClick {
                        Show-UDToast -Message "Test"
                    }
                }
            ) -AutoHeight $true -AutoSizeColumns $true    

        }
    }

}
$Pages += New-UDPage -Name 'Databases' -Content {
    New-UDTypography -Text 'diags'

}
New-UDApp -Pages $Pages -Title 'SQL Instance Dashboard'