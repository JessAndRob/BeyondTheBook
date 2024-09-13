New-UDApp -Content {
    Get-UDPage -Name server

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDDataGrid -LoadRows {
                $Data = Invoke-RestMethod -Uri http://localhost:5000/databases 
                $Data | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
                New-UDDataGridColumn -Field SqlInstance
                New-UDDataGridColumn -Field Name
                New-UDDataGridColumn -Field Status
                New-UDDataGridColumn -Field Compatibility
                New-UDDataGridColumn -Field LastFullBackup
                New-UDDataGridColumn -Field LastDiffBackup
                New-UDDataGridColumn -Field LastLogBackup
                # Button to do a backup of the database
                New-UDDataGridColumn -Field Name -Title "Backup" -Render {
                    New-UDButton -Text "Backup" -OnClick {
                        $Database = $EventData
                        $null = Invoke-RestMethod -Uri http://localhost:5000/backup -Method Post -Body $Database
                    }
                }
            ) -AutoHeight $true -AutoSizeColumns $true    
        }
    }





} -Navigation (
    New-UDList -Children {
        New-UDListItem -Label "Home"
        New-UDListItem -Label "Getting Started" -Children {
            New-UDListItem -Label "Installation" -OnClick {}
            New-UDListItem -Label "Usage" -OnClick {}
            New-UDListItem -Label "FAQs" -OnClick {}
            New-UDListItem -Label "System Requirements" -OnClick {}
            New-UDListItem -Label "Purchasing" -OnClick {}
        }
    }
) -NavigationLayout permanent