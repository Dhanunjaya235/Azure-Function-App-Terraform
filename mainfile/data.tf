data "azurerm_client_config" "current" {}

# data "azurerm_storage_account" "storage_account" {
#   name                = "acegnusedev1sa"
#   resource_group_name = "ace-gn-use-dev1-rg"
# }

# data "azurerm_eventhub_namespace" "eventhub_ns" {
#   name                = "ace-gn-use-dev1-ehns"
#   resource_group_name = "ace-gn-use-dev1-rg"
# }

# data "azurerm_servicebus_namespace" "servicebus_ns" {
#   name                = "ace-gn-use-dev1-sbn"
#   resource_group_name = "ace-gn-use-dev1-rg"
# }