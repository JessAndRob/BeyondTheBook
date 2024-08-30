New-UDApp -Content {

    New-UDGrid -Container -Content {
        New-UDGrid -Item -ExtraSmallSize 12 -Content {
            New-UDDataGrid -LoadRows {
                $Data = @(
                    @{ Name = 'Adam'; Number = Get-Random }
                    @{ Name = 'Tom'; Number = Get-Random }
                    @{ Name = 'Sarah'; Number = Get-Random }
                )
                $Data | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
                New-UDDataGridColumn -Field name
                New-UDDataGridColumn -Field number
            ) -AutoHeight $true

        }
        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            New-UDDataGrid -LoadRows {
                $Data = Get-ComputerInfo | select OsName, CsModel
                $Data | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
                New-UDDataGridColumn -Field OSName
                New-UDDataGridColumn -Field CsModel
            ) -AutoHeight $true -AutoSizeColumns $true

        }
        New-UDGrid -Item -ExtraSmallSize 6 -Content {
            New-UDPaper -Content { "xs-6" } -Elevation 2
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