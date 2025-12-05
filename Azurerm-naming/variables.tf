variable "resource_type_map" {
  type = map(any)
  default = {
    "virtual_network"                             = "vnet"
    "function_subnet"                             = "fsn"
    "private_endpoint_subnet"                     = "pesn"
    "private_dns_zone_virtual_network_link"       = "pdzvnl"
    "private_dns_zone"                            = "pdz"
    "private_dns_zone_group"                      = "pdzg"
    "subnet"                                      = "sn"
    "network_security_group"                      = "nsg"
    "route_table"                                 = "rt"
    "storage_account"                             = "sa"
    "private_endpoint"                            = "pe"
    "private_endpoint_connection"                 = "pec"
    "public_ip"                                   = "pip"
    "log_analytics"                               = "log"
    "log_analytics_workspace"                     = "law"
    "application_gateway"                         = "appgw"
    "diagnostic_settings"                         = "ds"
    "keyvault"                                    = "kv"
    "user_assigned_identity"                      = "umi"
    "logic_app"                                   = "la"
    "logic_app_plan"                              = "lap"
    "app_service_plan"                            = "asp"
    "appinsights"                                 = "appins"
    "waf_policy"                                  = "wafp"
    "service_bus_queue"                           = "sbq"
    "service_bus_namespace"                       = "sbn"
    "service_bus_topic"                           = "sbt"
    "service_bus_subscription"                    = "sbs"
    "autoscale_setting"                           = "amas"
    "autoscale_setting_profile"                   = "amasp"
    "azure_monitor_private_link_scope"            = "ampls"
    "azurerm_monitor_private_link_scoped_service" = "amplss"
    "eventhub_name"                               = "eh"
    "eventhub_namespace"                          = "ehns"
    "eventhub_rule"                               = "ehrl"
    "azurerm_data_collection_endpoint"            = "dce"
    "azurerm_data_collection_rule"                = "dcr"
    "resource_group"                              = "rg"
    "functionapp_name"                            = "func"
    "spfunc_name"                                 = "spfunc"
    ""                                            = ""
  }
  validation {
    condition     = length(distinct(keys(var.resource_type_map))) == length(distinct(values(var.resource_type_map)))
    error_message = "Recheck Keys and values, it is possible there are non unique keys or values."
  }
}

variable "resource_type" {
  type = string
}

variable "application_name_map" {
  type = map(any)
  default = {
    "ace-compliance-engine" = "ace-ce"
    "ace-guardian"          = "ace-gn"
    ""                      = ""
  }
}

variable "application_name" {
  type = string
}

variable "environment_map" {
  type = map(any)
  default = {
    "test" = "test"
    "prod" = "prod"

    // dev envs
    "dev"  = "dev"
    "dev1" = "dev1"
    "dev2" = "dev2"
    "dev3" = "dev3"
    "dev4" = "dev4"
  }
}

variable "environment" {
  type = string
}

variable "location_map" {
  type = map(any)
  default = {
    "eastus"  = "use"
    "eastus2" = "use2"
    "westus"  = "usw"
  }
}

variable "location" {
  type = string
}
