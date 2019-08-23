locals {
  tags = {
    Name = "${var.solutionName}-${var.environment}"
    Solution = "${var.solutionName}"
    KubernetesCluster = "${var.clusterName}"
    Environment = "${var.environment}"
    Tenant = "${var.tenantId}"
    Namespace = "${var.solutionName}-${var.environment}-${var.tenantId}"
  }
}

module "resourceGroup" {
  source = "modules/resourceGroup"

  # Variables:
  solution            = "${var.solutionName}"
  resource_group_name = "${var.rgName}"
  location            = "${var.location}"
  environment         = "${var.environment}"
  tags                = "${local.tags}"
}

locals {
  resource_group_name = "${element(split("/",module.resourceGroup.resourceGroup_id), (length(split("/",module.resourceGroup.resourceGroup_id)) - 1))}"
}

module "azureDBforPG" {
  source              = "modules/azureDBforPG"
  resource_group_name = "${local.resource_group_name}"

  # Variables:
  solution = "${var.solutionName}"

  #resource_group_name = "${var.rgName}"
  environment = "${var.environment}"
  tags        = "${local.tags}"

  #location         = "${var.location}"
  PGsku            = "${var.PGsku}"
  PGstorageProfile = "${var.PGstorageProfile}"
  PGadminName      = "${var.PGadminName}"
  PGversion        = "${var.PGversion}"
  PGdbNames        = "${var.PGdbNames}"
  PGcharset        = "${var.PGcharset}"
  PGcollation      = "${var.PGcollation}"
  sourceIPs        = "${var.sourceIPs}"
  PGpassword       = "${var.PGpassword}"

  azDbName = "${var.azDbName}"
}
