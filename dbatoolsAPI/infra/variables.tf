variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL server"
  type        = string
}

variable "administrator_login" {
  description = "The administrator login for the SQL server"
  type        = string
}

variable "administrator_login_password" {
  description = "The administrator login password for the SQL server"
  type        = string
  sensitive   = true
}

variable "sql_database_name" {
  description = "The name of the SQL database"
  type        = string
}

variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
}

variable "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Storage Account"
  type        = string
}

variable "storage_account_access_key" {
  description = "The access key for the Storage Account"
  type        = string
  sensitive   = true
}