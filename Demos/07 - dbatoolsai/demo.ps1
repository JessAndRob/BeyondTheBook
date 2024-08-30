Start-Process https://github.com/potatoqualitee/dbatools.ai
Install-Module dbatools.ai

Invoke-WebRequest -Uri https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2022.bak -OutFile \\sql1\c$\temp\AdventureWorks2022LT.bak
Invoke-WebRequest -Uri https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak -OutFile \\sql1\c$\temp\AdventureWorks2022.bak
Restore-DbaDatabase -SqlInstance sql1 -Path C:\temp\AdventureWorks2022.bak -UseDestinationDefaultDirectories

$env:OPENAI_API_KEY = ''

Get-DbaDatabase -SqlInstance sql1  -Database AdventureWorks2022 | New-DbaiAssistant -Name gpt4o-mini  -Description on -Model gpt-4o-mini-2024-07-18

$PSDefaultParameterValues =@{
    "Invoke-DbaiQuery:SqlInstance" = "sql1"
    "Invoke-DbaiQuery:Database" = "AdventureWorks2022"
    "Invoke-DbaiQuery:AssistantName" = "gpt4o-mini"
    "Invoke-DbatoolsAI:AssistantName" = "gpt4o-mini"
}


Invoke-DbaiQuery  -Message "What questions can I ask about the database" 

dbai what questions can i ask about the database

# hmmm - it no worky - so

Invoke-DbatoolsAI -Message "Copy the AdventureWorks2022 database from sql1 to sql2 using the network share \\sql1\c$\temp"

#or

dtai Copy the SalesDB database from ServerA to ServerB using the network share \\NetworkPath