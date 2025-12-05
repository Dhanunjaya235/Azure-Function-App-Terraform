module "naming" {
  source = "../Azurerm-naming"
  for_each = toset([
    "virtual_network",
    "subnet",
    "private_endpoint",
    "storage_account",
    "route_table",
    "keyvault",
    "resource_group",
    "network_security_group",
    "private_dns_zone_virtual_network_link",
    "private_dns_zone_group",
    "private_endpoint_connection",
    "eventhub_name",
    "eventhub_namespace",
    "eventhub_rule",
    "user_assigned_identity",
    "functionapp_name",
    "spfunc_name"
  ])
  resource_type    = each.value
  environment      = var.environment
  location         = var.location
  application_name = var.application_name
}


module "resource_group" {
  source   = "../Azure-resourcegroup"
  name     = module.naming["resource_group"].name
  location = var.location
  tags     = {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = module.naming["virtual_network"].name
  location            = var.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "function" {
  name                 = module.naming["subnet"].name
  resource_group_name  = module.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "webapp-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "private_endpoint" {
  name                           = module.naming["private_endpoint"].name
  resource_group_name            = module.resource_group.name
  virtual_network_name           = azurerm_virtual_network.vnet.name
  address_prefixes               = ["10.0.2.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_user_assigned_identity" "umi" {
  name                = module.naming["user_assigned_identity"].name
  location            = var.location
  resource_group_name = module.resource_group.name
}

module "functionapp" {
  source = "../Azurerm-functionapp"
  #resource_group = module.resource_group
  functionapp_name    = module.naming["functionapp_name"].name
  spfunc_name         = module.naming["spfunc_name"].name
  resource_group_name = module.resource_group.name
  resource_group_id   = module.resource_group.id
  location            = var.location
  umi_id              = azurerm_user_assigned_identity.umi.id
  storage_account_name = var.storage_account_name
  subnet_id           = azurerm_subnet.function.id
  subnet_pe_id        = azurerm_subnet.private_endpoint.id
  function_package_url = var.function_package_url
  eventhub_namespace   = var.eventhub_namespace
  umi_client_id       = azurerm_user_assigned_identity.umi.client_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
}