output "PostgreSQL_id" {
  value = "${azurerm_postgresql_server.postgreSQLServer.id}"
}

output "PostgreSQL_fqdn" {
  value = "${azurerm_postgresql_server.postgreSQLServer.fqdn}"
}
