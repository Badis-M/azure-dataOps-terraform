variable "project_name" {
  description = "The name of the project used for resource naming"
  type        = string
  default     = "dataopsmini"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "sql_admin_login" {
  description = "Admin login for Azure SQL Database"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Admin password for Azure SQL Database (use a secure value in production)"
  type        = string
  sensitive = true
}