# we need a module and then to install PowerShell Universla
# as admin
Install-Module Universal
Install-PSUServer

# go to the dashboard and look at apis
# test it there
# test it here
Invoke-RestMethod -uri http://localhost:5000/servers

