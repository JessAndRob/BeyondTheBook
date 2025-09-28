# create a self-hosted runner

# docs here:
https://github.com/organizations/JessAndRob/settings/actions/runners/new?arch=x64&os=win

# Create a folder under the drive root
Set-Location C:\
New-Item -Path actions-runner-btb -ItemType Directory
Set-Location actions-runner-btb

# Download the latest runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.322.0/actions-runner-win-x64-2.322.0.zip -OutFile actions-runner-win-x64-2.322.0.zip

# Optional: Validate the hash
if((Get-FileHash -Path actions-runner-win-x64-2.322.0.zip -Algorithm SHA256).Hash.ToUpper() -ne 'ace5de018c88492ca80a2323af53ff3f43d2c82741853efb302928f250516015'.ToUpper()){ throw 'Computed checksum did not match' }

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.322.0.zip", "$PWD")

# Create the runner and start the configuration experience
./config.cmd --url https://github.com/JessAndRob --token ** # get this from the url above

# Run it!
./run.cmd

## current articles
Get-DbaReplArticle -SqlInstance sql1 -Publication testPub | Format-Table

## look at the issue template
code .\.github\ISSUE_TEMPLATE\AddArticle.yaml

## look at the action
code .\.github\workflows\replication.yaml

## GO CREATE AN ISSUE and watch the workflow
    # Database: AdventureWorksLT2022
    # Publication: testPub
    # Schema: SalesLT
    # Article: Product

## check on the articles
Get-DbaReplArticle -SqlInstance sql1 -Publication testPub | Format-Table

## look at replication monitor