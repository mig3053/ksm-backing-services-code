resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = "${merge(
    map("Environment", "${var.environment}", "Solution", "${var.solution}"),
    "${var.tags}")}"
}
