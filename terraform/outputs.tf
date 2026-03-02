# terraform/outputs.tf
output "storage_account_name" {
  description = "The name of the created storage account"
  value       = azurerm_storage_account.datalake.name
}