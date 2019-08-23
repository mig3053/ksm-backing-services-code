Terraform module to create a Azure Database for PostgreSQL

Variables:
solution - the name of the solution. Used in tags. Participates in DB server name creation.
environment - the name of the environment. Used in tags. Participates in DB server name creation.

resource_group_name - the name of the resource group name to be deployed into. It uses data source for the resource group (resource group might exist in advance)
tags - additional tags, as map


PGsku - SKU for the PostgreSQL server as a map
PGstorageProfile - storage profile for the PostgreSQL server as a map

PGadminName - name for PostgreSQL admin user

PGversion - version of the PostgreSQL - 9.5, 9.6 or 10.0
PGpassword - password for admin user
PGdbNames - a list of database names (they might be as many as needed)
PGcharset - Charset for the DBs
PGcollation - Collation for the DBs
sourceIPs - a list of lists. Example:
    [
        ["startIPofRange01", "endIPofRange01"],
        ["startIPofRange02", "endIPofRange02"],
    ]