# create a self-hosted runner

# docs here:
https://github.com/organizations/JessAndRob/settings/actions/runners/new?arch=x64&os=win

# Create a folder under the drive root
mkdir actions-runner; cd actions-runner

# Download the latest runner package
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-win-x64-2.319.1.zip -OutFile actions-runner-win-x64-2.319.1.zip

# Optional: Validate the hash
if((Get-FileHash -Path actions-runner-win-x64-2.319.1.zip -Algorithm SHA256).Hash.ToUpper() -ne '1c78c51d20b817fb639e0b0ab564cf0469d083ad543ca3d0d7a2cdad5723f3a7'.ToUpper()){ throw 'Computed checksum did not match' }

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.319.1.zip", "$PWD")

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

## check on the articles
Get-DbaReplArticle -SqlInstance sql1 -Publication testPub | Format-Table

## look at replication monitor