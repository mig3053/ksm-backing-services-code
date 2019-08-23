location = "East US"

rgName = "TestRG"

tags = {
  KillDate = "20180704"
  CC       = "Yellow"
  Owner    = "Pavel Dokov"
}

solutionName = "SolutionA"

environment = "Test"

PGsku = {
  name     = "GP_Gen5_8"
  capacity = 8
  tier     = "GeneralPurpose"
  family   = "Gen5"
}

PGstorageProfile = {
  storage_mb            = 5120
  backup_retention_days = 35
  geo_redundant_backup  = "Enabled"
}

PGadminName = "pgadminuser"

PGversion = "9.5" # Other options: "9.6", "10.0"

PGdbNames = [
  "PGDBName01",
  "PGDBName02",
  "PGDBName03",
  "PGDBName04",
  "PGDBName05",
  "PGDBName06",
]

PGcharset = "UTF8"

PGcollation = "English_United States.1252"

sourceIPs = [
  ["0.0.0.0", "10.10.10.10"],
  ["10.10.10.10", "20.20.20.20"],
  ["20.20.20.20", "30.30.30.30"],
  ["30.30.30.30", "40.40.40.40"],
  ["40.40.40.40", "50.50.50.50"],
  ["50.50.50.50", "255.255.255.255"],
]
