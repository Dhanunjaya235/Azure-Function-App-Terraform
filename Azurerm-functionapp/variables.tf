variable "environment" {
  description = "environment to which this var file is deployed"
  type = string
  default = "dev3"
}

variable "application_name" {
  description = "ace-compliance-engine"
  type = string
  default = "ace-guardian"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Resource group location"
}

variable "vnet_name" {
  type = string
  default = "vnet-default"
  description = "Name of the predefined VNet"
}

variable "vnet_resource_group_name" {
  type = string
  default = "ace-rg-default"
  description = "Name of the predefined VNet's Resource Group"
}

variable "subnet_info" {
  description = "Values used to generate subnets"

  // key name is used as Subnet Name
  type = map(object({
    subnet_address_space              = list(string)
    security_rules                    = list(any)
    tags                              = map(string)
    privateEndpointNetworkPolicies    = string
    privateLinkServiceNetworkPolicies = string
  }))

  default = {
    "PrivateEndPointSubnet" = {
      subnet_address_space = ["10.252.13.96/28"]
      security_rules = [
        {
          name                       = "AllowTCPInboundFromJPMC"
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefixes    = ["170.148.0.0/16", "146.143.0.0/16", "103.246.196.0/23", "161.121.0.0/16", "159.53.0.0/16"]
          destination_address_prefix = "*"

          source_address_prefix = null
          source_port_ranges = null
          destination_port_ranges = null
          destination_address_prefixes = null
        }
      ]
      tags = {}
      privateEndpointNetworkPolicies = "Enabled"
      privateLinkServiceNetworkPolicies = "Disabled"
    }
    "WorkloadSubnet" = {
      subnet_address_space = ["10.252.13.112/28"]
      security_rules = [
        {
          name                       = "AllowTCPInboundFromJPMC"
          priority                   = 300
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefixes    = ["170.148.0.0/16", "146.143.0.0/16", "103.246.196.0/23", "161.121.0.0/16", "159.53.0.0/16"]
          destination_address_prefix = "*"

          source_address_prefix = null
          source_port_ranges = null
          destination_port_ranges = null
          destination_address_prefixes = null
        }
      ]
      tags = {}
      privateEndpointNetworkPolicies = "Enabled"
      privateLinkServiceNetworkPolicies = "Disabled"
    }
  }
}

variable "private_zones_info" {
  description = "Values used to generate private DNS zones"

  // for what to call each zone based on service need
  // see https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns

  type = map(object({
    private_dns_zone_name = string
    dns_vnet_link_name    = string
  }))

  default = {
    "table" = {
      private_dns_zone_name = "privatelink.table.core.windows.net"
      dns_vnet_link_name    = "table"
    }
    "blob" = {
      private_dns_zone_name = "privatelink.blob.core.windows.net"
      dns_vnet_link_name    = "blob"
    }
    "keyvault" = {
      private_dns_zone_name = "privatelink.vaultcore.azure.net"
      dns_vnet_link_name    = "keyvault"
    }
    "queue" = {
      private_dns_zone_name = "privatelink.queue.core.windows.net"
      dns_vnet_link_name    = "queue"
    }
    "eventhub" = {
      private_dns_zone_name = "privatelink.servicebus.windows.net"
      dns_vnet_link_name    = "eventhub"
    }
  }
}

variable "resource_group" {
  type = string
  description = "Resource Group Info"
  default = ""
}

variable "resource_group_name" {
  type = string
  default = ""
  description = "Resource Group Name"
}

variable "resource_group_id" {
  type = string
  description = "Resource Group ID"
  default = ""
}

variable umi_id {
    type = string
    description = "UMI ID for Event Hub"
    default = ""
}

#Function App variables

variable "functionapp_name" {
  type        = string
  description = "The name of Function App"
  default = ""
}

variable "spfunc_name" {
  type        = string
  description = "The name of Function App Service Plan"
  default = ""
}

variable "use_service_plan" {
  type        = bool
  description = "Toggle to deploy the Function App on a dedicated/premium App Service Plan. When false, the app is deployed on the Consumption plan without creating a service plan."
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for Function App"
  default = ""
}

variable "subnet_pe_id" {
  type        = string
  description = "Subnet ID for Function App Private Endpoint"
  default = ""
}

variable "storage_account_name" {
  type        = string
  description = "Storage Account Name for Function App"   
  default = ""
}

variable "allowed_origins" {
  description = "Allow Logic App to make CORS requests to:"
  type        = list(string)
  default = [
    "https://portal.azure.com"
  ]
}

variable "function_package_url" {
  type        = string
  description = "URL to the function app deployment package (zip file) in blob storage. Leave empty if deploying code separately."
  default     = ""
}

variable "eventhub_namespace" {
  type        = string
  description = "Event Hub namespace FQDN (e.g., my-ehns.servicebus.windows.net)"
  default     = ""
}

variable "umi_client_id" {
  type        = string
  description = "User Managed Identity Client ID for storage account access"
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Application Insights"
  default     = ""
}