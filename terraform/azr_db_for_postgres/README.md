Two terraform modules that create a resource group and Azure Database for PostgreSQL in the resource groups.
Please look at file "variables.tfvars" as an example of variables to be used. Variable 'PGpassword' is the password for the PostgreSQL admin user. It is not specified in "variables.tfvars" file.

Backlog:
Look at VNET service endpoints - when it becomes GA, to be added to Terraform.
