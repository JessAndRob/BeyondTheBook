# Data API Builder

Set-Location '.\Demos\09 - Data API Builder'

# Install the tool
dotnet tool install --global Microsoft.DataApiBuilder

# need a SQL instance
# either locally or in a container
docker run -p 2500:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 -d dbatools/sqlinstance

# we have sql1 to use
Get-DbaDatabase -SqlInstance sql1 -ExcludeSystem | Select-Object Name

# Create the configuration
# sql1
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=sql1;User Id=sqladmin;Password=dbatools.IO!;Database=AdventureWorks2022;TrustServerCertificate=True;Encrypt=True;"

# Container
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,2500;User Id=sqladmin;Database=pubs;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"

# add an entity (case sensitive entity names)
dab add SalesPerson --source "Sales.SalesPerson" --permissions "anonymous:*"

# view the config file
code dab-config.json

# start the service
dab start

# go view the sites
# "http://localhost:5000" # shows it's healthy
# "http://localhost:5000/swagger" # shows the swagger page
# "http://localhost:5000/api/SalesPerson" # shows the data

# open another terminal

# get data from PowerShell
(Invoke-RestMethod -Uri "http://localhost:5000/api/SalesPerson").Value | Format-Table

# count the records
(Invoke-RestMethod -Uri "http://localhost:5000/api/SalesPerson").Value | Measure-Object

# insert data from PowerShell
$body = @{
      "BusinessEntityID" = 4
      "TerritoryID" = $null
      "SalesQuota" = $null
      "Bonus" = 0
      "CommissionPct" = 0
      "SalesYTD" = 559697.5639
      "SalesLastYear" = 0
      "rowguid" = "76bacc71-1b2e-4573-9c74-b0badafa6816"
      "ModifiedDate" = $(get-date)
} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5000/api/SalesPerson" -Method Post -Body $body -ContentType "application/json"

# verify the insert
(Invoke-RestMethod -Uri "http://localhost:5000/api/SalesPerson").Value | Format-Table

(Invoke-RestMethod -Uri "http://localhost:5000/api/SalesPerson").Value | Measure-Object

# Next steps
# Deploy to a container app\instance in Azure
# Add authentication