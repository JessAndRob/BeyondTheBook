Start-Process https://github.com/potatoqualitee/dbatools.ai
Install-Module dbatools.ai
Install-Module finetuna

$env:OPENAI_API_KEY = 'Just A Fake KEY here'

$AssistantName = 'Jen_AI_{0}' -f (Get-Random -Minimum 0 -Maximum 1000)

$DatabaseConfig = @{
    SqlInstance = 'sql1'
    Database    = 'AdventureWorks2022'
}

$AssistantConfig = @{
    Name        = $AssistantName
    Description = 'A test Assistant for looking at the AdventureWorks database'
    Model =  'gpt-4o-mini'
}

Get-DbaDatabase  @DatabaseConfig | New-DbaiAssistant @AssistantConfig

$PSDefaultParameterValues = @{
    "Invoke-DbaiQuery:SqlInstance"    = "sql1"
    "Invoke-DbaiQuery:Database"       = "AdventureWorks2022"
    "Invoke-DbaiQuery:AssistantName"  = $AssistantName
}


Invoke-DbaiQuery  -Message "What questions can I ask about the database" 

# It can be amazing

dbai list all of the categories

dbai list all acive vendors

dbai What is the total sales revenue for the latest month

dbai when were the last 3 orders

dbai what was the total sales reveue for June 2014
dbai what was the total sales reveue for May 2014
dbai what was the total sales reveue for April 2014

dbai which month had the highest sales revenue in 2014 and how much was it

# sometimes not so good

dbai which city has the most customers

dbai where are the most customers

dbai which country has the most customers

dbai Get a list of employees and their job titles.

dbai How many products are in the Bikes category?

dbai what is the status of the latest purchase order?

dbai what does a status of 2 mean

$dbatoolsAssistantName = 'Jen_AI_{0}' -f (Get-Random -Minimum 0 -Maximum 1000)

$AssistantConfig = @{
    Name        = $dbatoolsAssistantName
    Description = 'A test Assistant for dbatools'
    Model =  'gpt-4o-mini'
}
New-DbaiAssistant @AssistantConfig

$PSDefaultParameterValues['Invoke-DbatoolsAI:AssistantName'] = $dbatoolsAssistantName

Get-DbaDatabase -SqlInstance sql1,sql2 -ExcludeSystem |Select SqlInstance, Name

Invoke-DbatoolsAI -Message "Copy the AdventureWorks2022 database from sql1 to sql2 using the network share \\\\sql1\\c$\\backups" -Verbose

Get-DbaDatabase -SqlInstance sql1,sql2 -ExcludeSystem |Select SqlInstance, Name
