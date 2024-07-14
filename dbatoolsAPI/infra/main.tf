# we need a provider to interact with Azure
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }

  # Update this block with the location of your terraform state file
  backend "azurerm" {
    resource_group_name  = "rg-terraform-github-actions-state"
    storage_account_name = "tfgithubpassbtb"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_oidc             = true
  }
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# create a sql server with a database that is a sample of adventureworks
resource "azurerm_mssql_server" "sql" {
  name                          = var.sql_server_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12.0"
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags = {
    environment = "dev"
  }
}

resource "azurerm_mssql_database" "db" {
  server_id = azurerm_mssql_server.sql.id
  name      = var.sql_database_name
  collation = "SQL_Latin1_General_CP1_CI_AS"
  tags = {
    environment = "dev"
  }
}


# create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
  tags = {
    environment = "dev"
  }
}

# create an app service plan
resource "azurerm_service_plan" "plan" {
  name                = "appserviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "Y1"
  location            = azurerm_resource_group.rg.location

  tags = {
    environment = "dev"
  }
}

# create a PowerShell function app
resource "azurerm_linux_function_app" "func" {
  name                          = var.function_app_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  service_plan_id               = azurerm_service_plan.plan.id
  storage_account_name          = azurerm_storage_account.sa.name
  storage_account_access_key    = var.storage_account_access_key
  public_network_access_enabled = false
  https_only                    = true
  site_config {
  }
  tags = {
    environment = "dev"
  }
}
