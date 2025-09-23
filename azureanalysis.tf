terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-data-analytics"
  location = "East US"
}

# Storage Account (Data Lake Gen2)
resource "azurerm_storage_account" "lake" {
  name                     = "datalakestg${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  is_hns_enabled           = true
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "adf-data-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Azure Synapse Workspace
resource "azurerm_synapse_workspace" "synapse" {
  name                                 = "synapse-workspace-analytics"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_fs.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password      = "P@ssword123!"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_fs" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.lake.id
}

# Azure Analysis Services
resource "azurerm_analysis_services_server" "aas" {
  name                = "analysis-sv-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "S1"
  admin_users         = ["user@yourtenant.onmicrosoft.com"]
}

# Optional: Azure SQL Database (one of the data sources)
resource "azurerm_sql_server" "sql" {
  name                         = "sqlserver-analytics"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "P@ssword123!"
}

resource "azurerm_sql_database" "sqldb" {
  name                = "sqldb-analytics"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sql.name
  sku_name            = "S0"
}

# Cosmos DB (another data source)
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "cosmosacctanalytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }
}
