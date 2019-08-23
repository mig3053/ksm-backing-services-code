output "resourceGroup_id" {
  value = "${module.resourceGroup.resourceGroup_id}"
}

output "PostgreSQL_id" {
  value = "${module.azureDBforPG.PostgreSQL_id}"
}

output "PostgreSQL_fqdn" {
  value = "${module.azureDBforPG.PostgreSQL_fqdn}"
}
