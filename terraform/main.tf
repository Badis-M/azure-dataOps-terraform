# Generate a random string for global uniqueness of the storage account
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 1. Resource Group: The logical container
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = var.location
}

# 2. Storage Account: Configured as ADLS Gen2
resource "azurerm_storage_account" "datalake" {
  name                     = "st${var.project_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # Lowest cost option (Locally Redundant)
  is_hns_enabled           = true  # THIS enables Data Lake Gen2 features

  tags = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

# 3. Storage Container: Our 'Raw' data landing zone
resource "azurerm_storage_container" "raw_zone" {
  name                  = "raw-data"
  storage_account_name  = azurerm_storage_account.datalake.name
  container_access_type = "private"
}

# 4. Azure Data Factory: The Orchestrator
resource "azurerm_data_factory" "adf" {
  name                = "adf-${var.project_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    environment = "dev"
  }
}

# 5. SQL Server (The logical host)
resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-server-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

# 6. SQL Database (Configured for the Free/Basic Tier)
resource "azurerm_mssql_database" "sql_db" {
  name         = "sqldb-dataops"
  server_id    = azurerm_mssql_server.sql_server.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "BasePrice"
  max_size_gb  = 2
  sku_name     = "Basic" # Most cost-effective tier

  tags = {
    environment = "dev"
  }
}

# 7. Firewall Rule
# Allows Azure services (like GitHub Actions and Data Factory) to access the database
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}