Start-Process https://github.com/potatoqualitee/dbatools.ai
Install-Module dbatools.ai
Install-Module finetuna

$env:OPENAI_API_KEY = 'Just A Fake KEY here'

Get-DbaDatabase -SqlInstance sql1  -Database AdventureWorks2022 | New-DbaiAssistant -Name gpt4o-mini_1  -Description on -Model gpt-4o-mini

$PSDefaultParameterValues =@{
    "Invoke-DbaiQuery:SqlInstance" = "sql1"
    "Invoke-DbaiQuery:Database" = "AdventureWorks2022"
    "Invoke-DbaiQuery:AssistantName" = "gpt4o-mini_1"
    "Invoke-DbatoolsAI:AssistantName" = "gpt4o-mini_1"
}


Invoke-DbaiQuery  -Message "What questions can I ask about the database" -SqlInstance sql1  -Database AdventureWorks2022

dbai what questions can i ask about the database

# hmmm - it no worky - so

Invoke-DbatoolsAI -Message "Copy the AdventureWorks2022 database from sql1 to sql2 using the network share \\sql1\c$\temp"

#or

dtai Copy the SalesDB database from ServerA to ServerB using the network share \\NetworkPath