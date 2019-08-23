resource "azurerm_postgresql_server" "postgreSQLServer" {
  name                = "${lower("${var.azDbName}")}"
  location            = "${data.azurerm_resource_group.resourceGroup.location}"         #"${var.location}"
  resource_group_name = "${data.azurerm_resource_group.resourceGroup.name}"             #"${var.resource_group_name}"

  sku {
    name     = "${var.PGsku["name"]}"
    capacity = "${var.PGsku["capacity"]}"
    tier     = "${var.PGsku["tier"]}"
    family   = "${var.PGsku["family"]}"
  }

  storage_profile {
    storage_mb            = "${var.PGstorageProfile["storage_mb"]}"
    backup_retention_days = "${var.PGstorageProfile["backup_retention_days"]}"
    geo_redundant_backup  = "${var.PGstorageProfile["geo_redundant_backup"]}"
  }

  administrator_login          = "${var.PGadminName}"
  administrator_login_password = "${var.PGpassword}"
  version                      = "${var.PGversion}"
  ssl_enforcement              = "Enabled"

  tags = "${merge(
    map("Environment", "${var.environment}", "Solution", "${var.solution}"),
    "${var.tags}")}"
}

resource "azurerm_postgresql_database" "PGdatabase" {
  count               = "${length(var.PGdbNames)}"
  name                = "${lower(element(var.PGdbNames, count.index))}"
  resource_group_name = "${data.azurerm_resource_group.resourceGroup.name}"  #"${var.resource_group_name}"
  server_name         = "${azurerm_postgresql_server.postgreSQLServer.name}"
  charset             = "${var.PGcharset}"
  collation           = "${var.PGcollation}"
}

resource "azurerm_postgresql_firewall_rule" "PGfirewallRule" {
  count               = "${length(var.sourceIPs)}"
  name                = "range-${count.index}"
  resource_group_name = "${data.azurerm_resource_group.resourceGroup.name}"  #"${var.resource_group_name}"
  server_name         = "${azurerm_postgresql_server.postgreSQLServer.name}"
  start_ip_address    = "${element(var.sourceIPs[count.index], 0)}"
  end_ip_address      = "${element(var.sourceIPs[count.index], 1)}"
}
