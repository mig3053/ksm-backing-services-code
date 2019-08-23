output "resource_group_name" {
  value = "${azurerm_resource_group.rg.name}"
}

output "storage_account_name" {
  value = "${azurerm_storage_account.account.name}"
}

output "access_key" {
  value = "${azurerm_storage_account.account.primary_access_key}"
}
