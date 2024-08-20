Return 'Oi, You may be an MVP but this is a demo, don''t run the whole thing, fool!!'

# This will be a quick introduction to dbatools for those that haven't used it before.

#region Getting a PowerShell module  <----- ANY PowerShell module
# How do you get it?

# Trust the repository

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# the new way
Set-PSResourceRepository -Name PSGallery -InstallationPolicy Trusted

# Install the module
$modulename = 'dbatools'
Install-Module -Name $modulename

# the new way
Install-PSResource -Name $modulename

#endregion

#region Finding commands and help <----- ANY PowerShell module
# How do you find commands?

# Get all commands in the module - This will work for any module
# Get-Command -Module $modulename
# but for dbatools, there are quite a few
Get-Command -Module $modulename | Measure-Object

# For any module you can use Get-Command with a filter to find commands
# this works for the name of the command, the noun, or the verb

Get-Command -Module $modulename -Name *login*
Get-Command -Module $modulename -Name *database*

# for dbatools, you can also use Find-DbaCommand
# this will search the command names, descriptions, and aliases
Find-DbaCommand -Pattern *login*
Find-DbaCommand -Pattern *database*

# For any module, you can use Get-Help

Get-Help Get-DbaDatabase
Get-Help Get-DbaDatabase -Full
Get-Help Get-DbaDatabase -Examples
Get-Help Get-DbaDatabase -ShowWindow

#endregion

#region Connecting to SQL Server <----- dbatools only

# How do you connect to SQL Server?

# You can use the -SqlInstance parameter on any dbatools command
# This will connect to the default instance on the local machine
Get-DbaDatabase -SqlInstance sql1

# You can also use the -SqlCredential parameter interactively

Get-DbaDatabase -SqlInstance sql1 -SqlCredential sqladmin

# You can also use the -SqlCredential parameter with a PSCredential object

$pass = ConvertTo-SecureString 'dbatools.IO!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ('sqladmin', $pass)
Get-DbaDatabase -SqlInstance sql1 -SqlCredential $cred

# the Get-dba* commands will not make any changes, they will return information only

# BUT they are still running on your instance, still using resources and also connecting with your account

Get-DbaAgentJob -SqlInstance sql1
Get-DbaClientAlias
Get-DbaDbBackupHistory -SqlInstance sql1
Get-DbaDbccProcCache -SqlInstance sql1
Get-DbaFile -SqlInstance sql1

New-DbaLogin -SqlInstance sql1 -SqlCredential $cred -Login
New-DbaServerRole -SqlInstance sql1 -Role 'MyNewRole'

Add-DbaServerRoleMember

Set-DbaDbOwner
Set-DbaMaxMemory

Remove-dba

#endregion

