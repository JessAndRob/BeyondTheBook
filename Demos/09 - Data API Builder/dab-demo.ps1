# Data API Builder

Set-Location '.\Demos\09 - Data API Builder'

# Install the tool
dotnet tool install --global Microsoft.DataApiBuilder

# need a SQL instance
# either locally or in a container
docker run -p 2500:1433 --volume shared:/shared:z --name mssql1 --hostname mssql1 -d dbatools/sqlinstance

# Create the configuration
# sql1
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=sql1;User Id=sqladmin;Database=AdventureWorks2022;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"
# Container
dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,2500;User Id=sqladmin;Database=pubs;Password=dbatools.IO;TrustServerCertificate=True;Encrypt=True;"

# add an entity (case sensitive entity names)
dab add Author --source "dbo.authors" --permissions "anonymous:*"

# view the config file
code dab-config.json

# start the service
dab start

# go view the sites
# "http://localhost:5000" # shows it's healthy
# "http://localhost:5000/swagger" # shows the swagger page
# "http://localhost:5000/api/author" # shows the data

# open another terminal

# get data from PowerShell
(Invoke-RestMethod -Uri "http://localhost:5000/api/Author").Value | Format-Table

# count the records
(Invoke-RestMethod -Uri "http://localhost:5000/api/Author").Value | Measure-Object

# insert data from PowerShell
$body = @{
    au_id = "999-99-9999"
    au_lname = "Smith"
    au_fname = "John"
    phone = "555-555-5555"
    address = "123 Main St"
    city = "Anytown"
    state = "CA"
    zip = "12345"
    contract = $false
} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:5000/api/Author" -Method Post -Body $body -ContentType "application/json"

# verify the insert
(Invoke-RestMethod -Uri "http://localhost:5000/api/Author").Value | Format-Table

(Invoke-RestMethod -Uri "http://localhost:5000/api/Author").Value | Measure-Object

# Next steps
# Deploy to a container app\instance in Azure
# Add authentication