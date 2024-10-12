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

dbai List all of the customers living in Southampton or in Manchester

dbai list all of the products in the bike category
# 

Invoke-DbatoolsAI -Message "Copy the AdventureWorks2022 database from sql1 to sql2 using the network share \\sql1\c$\temp"

#or

dtai Copy the SalesDB database from ServerA to ServerB using the network share \\NetworkPath


C:\GitHub> $PSDefaultParameterValues =@{                                             
    >>     "Invoke-DbaiQuery:SqlInstance" = "sql1"                                          
    >>     "Invoke-DbaiQuery:Database" = "AdventureWorks2022"
    >>     "Invoke-DbaiQuery:AssistantName" = "gpt4o-mini_1"
    >>     "Invoke-DbatoolsAI:AssistantName" = "gpt4o-mini_1"
    >> }
    PS C:\GitHub> 
    PS C:\GitHub> Invoke-DbaiQuery  -Message "What questions can I ask about the database" -SqlInstance sql1  -Database AdventureWorks2022
    You can ask a variety of questions about the database, including but not limited to:    
                                                                                            
    Customer Information:
    - What are the details of a specific customer by ID?
    - List all customers in a particular city or country.
    - Get contact information for all customers.
    
    Employee Information:
    - What are the details of a specific employee by ID?
    - List all employees in a specific department or job title.
    - Get a list of employees and their managers.
    
    Sales Information:
    - What are the total sales for a specific product?
    - List all sales orders for a particular customer.
    - What is the sales history for a specific period?
    
    Product Information:
    - What are the details of a specific product by ID?
    - List all products in a certain category.
    - What are the available inventory items in a specific location?
    
    Vendor Information:
    - Get information about a specific vendor.
    - List all vendors that provide a certain product.
    - What is the average lead time for product orders?
    
    Department Information:
    - List all departments and their details.
    - Find employees in a specific department.
    - What is the history of department changes for a specific employee?
    PS C:\GitHub> dbai How many bikes are currently for sale?
    To accurately generate a SQL query for the number of bikes currently for sale, I need to clarify whether you are referring to bicycles specifically available as products in the database, and if so, which criteria (such as product category or status) should be usedPS C:\GitHub> dbai How many bikes are currently for sale?
    To accurately generate a SQL query for the number of bikes currently for sale, I need to clarify whether you are referring to bicycles specifically available as products in the database, and if so, which criteria (such as product category or status) should be used to identify them. Could you please provide more specifics about what defines a "bike" in this context?
    PS C:\GitHub> dbai how man bikes are currentl for sale? A bike is defined using hte productcategor bike
    There are currently 0 bikes for sale in the database.
    PS C:\GitHub> dbai List all of the customers living in Southampton or in Manchester     
    WARNING: Invalid column name 'BusinessEntityID'.
    PS C:\GitHub> dbai List all of the customers living in Southampton
    WARNING: Invalid column name 'BusinessEntityID'.
    PS C:\GitHub> dbai list all of the products in the bike category
    Getting answer [Processing message 1 of 9                                            ]  
    
    There are no products currently listed in the bike category in the database.
    PS C:\GitHub> dbai list all of the products in the bikes category
    There are no products currently listed in the bikes category in the database.
    PS C:\GitHub> dbai list all of the products in the Bikes category
    There are no products currently listed in the Bikes category in the database.
    PS C:\GitHub> dbai what is the top customer by sales?            
    The top customer by sales has a CustomerID of 29818, with total sales amounting to 877,107.19.                                                                                  
    PS C:\GitHub> dbai what is the sales history for the last 3 quarters
    There is no sales history available for the last 3 quarters in the database.
    PS C:\GitHub>                                                                           
    