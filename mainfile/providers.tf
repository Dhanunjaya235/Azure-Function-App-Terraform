terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "1.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {
    template_deployment {
      delete_nested_items_during_deletion = false
    }
    key_vault {
      purge_soft_delete_on_destroy      = false
      recover_soft_deleted_key_vaults   = true
      recover_soft_deleted_certificates = true
      recover_soft_deleted_keys         = true
      recover_soft_deleted_secrets      = true
    }
  }
  storage_use_azuread = true
}