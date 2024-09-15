New-UDApp -Content {
    Get-UDPage -Name server

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDDataGrid -LoadRows {
                $Data = Invoke-RestMethod -Uri http://localhost:5000/servers 
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
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
        }
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
        }
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
        }
        New-UDGrid -Item -ExtraSmallSize 3 -Content {
            New-UDPaper -Content { "xs-3" } -Elevation 2
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