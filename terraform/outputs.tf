# terraform/outputs.tf
output "storage_account_name" {
  description = "The name of the created storage account"
  value       = azurerm_storage_account.datalake.name
}
output "sql_server_fqdn" {
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  description = "The fully qualified domain name of the SQL server"
}

output "sql_database_name" {
  value = azurerm_mssql_database.sql_db.name
}