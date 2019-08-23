resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.region}"
}

data "azurerm_subnet" "worker_subnet" {
  name                 = "${var.cluster_name}.${var.environment}.azr.nvt.mckinsey.cloud-worker-sn"
  virtual_network_name = "${var.cluster_name}.${var.environment}.azr.nvt.mckinsey.cloud-mckube-vnet"
  resource_group_name  = "${var.subscription}-${var.cluster_name}-${var.environment}-cluster-rg"
}

resource "azurerm_storage_account" "account" {
  name                = "${var.solution}${var.environment}${var.tenant}${var.instance_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  location                 = "${var.region}"
  account_tier             = "${var.tier}"
  account_replication_type = "${var.replication}"
  enable_https_traffic_only = true

  network_rules {
    ip_rules                   = ["${var.ip_whitelist}"]
    virtual_network_subnet_ids = ["${data.azurerm_subnet.worker_subnet.id}"]
  }

  tags {
    Environment       = "${var.environment}"
    Tenant            = "${var.tenant}"
    Solution          = "${var.solution}"
    KubernetesCluster = "${var.cluster_name}.${var.environment}.azr.nvt.mckinsey.cloud"
  }
}
