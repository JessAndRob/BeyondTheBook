# There are also modules for other things - like Fabric
Install-Module PSFabricTools

## Documentation
## https://github.com/data-masterminds/psfabrictools

## Set the configuration
Set-PSFabricConfig -WorkspaceGUID 'GUID-GUID-GUID-GUID' -DataWarehouseGUID 'GUID-GUID-GUID-GUID'

## This has a dependency on the PSFramework module - we saw it earlier for config and logging

#region List Recovery points

# Get the recovery points
Get-PSFabricRecoveryPoint

# If you haven't set the config you can pass in those parameters at run time:
Get-PSFabricRecoveryPoint -WorkspaceGUID 'guid-guid-guid-guid' -DataWarehouseGUID 'guid-guid-guid-guid'

## can also filter by time - I need a recovery point within the last 2 hours
Get-PSFabricRecoveryPoint -Since (get-date).AddHours(-2)

## or by specific time
Get-PSFabricRecoveryPoint -CreateTime '2024-07-23T09:42:36Z'

#endregion

#region create a recovery point

## Create a recovery point
New-PSFabricRecoveryPoint

# Or if you want to pass in the parameters you can
New-PSFabricRecoveryPoint -WorkspaceGUID 'guid-guid-guid-guid' -DataWarehouseGUID 'guid-guid-guid-guid'

#endregion

#region Restore a recovery point
Restore-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:04:03Z'

# If you want to see the progress and when the restore completes you can add the `-Wait` parameter and the command will check the API endpoint for progress until it is complete.
Restore-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:04:03Z'  -Wait
#endregion

#region Delete a recovery point
Remove-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:20:26Z'
#endregion