# Data Lake (already shown above)
resource "azurerm_storage_account" "lake2" {
  name                     = "datalakestg2${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
  is_hns_enabled           = true
}

# Data Factory
resource "azurerm_data_factory" "adf2" {
  name                = "adf-orchestration"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Logic App Standard
resource "azurerm_logic_app_workflow" "logicapp" {
  name                = "logicapp-orchestration"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Databricks
resource "azurerm_databricks_workspace" "dbx" {
  name                = "dbx-transform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "premium"
}

# Synapse (same as above)
