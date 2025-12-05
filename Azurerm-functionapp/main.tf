locals {
  # Build app settings dynamically based on provided variables
  base_app_settings = [
    {
      name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
      value = azurerm_application_insights.application_insights.connection_string
    },
    {
      name  = "APPINSIGHTS_INSTRUMENTATIONKEY"
      value = azurerm_application_insights.application_insights.instrumentation_key
    },
    {
      name  = "FUNCTIONS_EXTENSION_VERSION"
      value = "~4"
    },
    {
      name  = "FUNCTIONS_WORKER_RUNTIME"
      value = "python"
    },
    {
      name  = "WEBSITE_CONTENTOVERVNET"
      value = "1"
    },
    {
      name  = "AzureWebJobsStorage__accountName"
      value = var.storage_account_name
    },
    {
      name  = "AzureWebJobsStorage__clientId"
      value = var.umi_client_id != "" ? var.umi_client_id : "84fe47cc-d937-4473-9b05-b3e014afda2d"
    },
    {
      name  = "AzureWebJobsStorage__credential"
      value = "managedidentity"
    }
  ]

  package_settings = var.function_package_url != "" ? [
    {
      name  = "WEBSITE_RUN_FROM_PACKAGE"
      value = var.function_package_url
    },
    {
      name  = "WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID"
      value = var.umi_id
    }
  ] : []

  eventhub_settings = var.eventhub_namespace != "" ? [
    {
      name  = "EventHubConnection__credential"
      value = "managedidentity"
    },
    {
      name  = "EventHubConnection__fullyQualifiedNamespace"
      value = var.eventhub_namespace
    }
  ] : []

  app_settings = concat(local.base_app_settings, local.package_settings, local.eventhub_settings)
}

resource "azurerm_service_plan" "service_plan" {
  name                = var.spfunc_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = {}
  os_type                  = "Linux"
  per_site_scaling_enabled = false
  sku_name                 = "P1v3"
  worker_count             = 3
  zone_balancing_enabled   = true
}

resource "azurerm_application_insights" "application_insights" {
  name                = "${var.functionapp_name}-app-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type                      = "web"
  daily_data_cap_notifications_disabled = false
  disable_ip_masking                    = false
  force_customer_storage_for_profiler   = false
  internet_ingestion_enabled            = true
  internet_query_enabled                = true
  local_authentication_disabled         = true
  retention_in_days                     = 90
  sampling_percentage                   = 100
  # workspace_id                          = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : "/subscriptions/77509ee3-e5b4-4403-80df-c20c10665209/resourceGroups/ace-gn-use-dev1-rg/providers/Microsoft.OperationalInsights/workspaces/ace-gn-use-dev1-law"
}

resource "azapi_resource" "function_guardian" {
  type      = "Microsoft.Web/sites@2022-03-01"
  parent_id = var.resource_group_id
  name      = var.functionapp_name
  location  = var.location
  tags      = {}
  schema_validation_enabled = false
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.umi_id]
  }
  body = jsonencode({
    kind = "functionapp,linux"
    properties = {
      vnetImagePullEnabled      = true
      vnetContentShareEnabled   = true
      clientAffinityEnabled     = false
      clientCertEnabled         = false
      clientCertMode            = "Required"
      enabled                   = true
      hostNamesDisabled         = false
      httpsOnly                 = true
      hyperV                    = false
      isXenon                   = false
      keyVaultReferenceIdentity = "SystemAssigned"
      publicNetworkAccess       = "Disabled"
      redundancyMode            = "None"
      reserved                  = true
      scmSiteAlsoStopped        = false
      serverFarmId              = azurerm_service_plan.service_plan.id
      storageAccountRequired    = false
      virtualNetworkSubnetId    = var.subnet_id
      cors = {
          "allowedOrigins"     = var.allowed_origins,
          "supportCredentials" = false
        }
      siteConfig = {
        autoHealEnabled            = false
        acrUseManagedIdentityCreds = false
        alwaysOn                   = true
        appSettings = local.app_settings
        azureStorageAccounts                   = {}
        detailedErrorLoggingEnabled            = true
        functionAppScaleLimit                  = 0
        functionsRuntimeScaleMonitoringEnabled = false
        ftpsState                              = "FtpsOnly"
        http20Enabled                          = false
        #ipSecurityRestrictionsDefaultAction    = "Deny"
        linuxFxVersion                         = "python|3.11"
        localMySqlEnabled                      = false
        loadBalancing                          = "LeastRequests"
        minTlsVersion                          = "1.2"
        minimumElasticInstanceCount            = 0
        numberOfWorkers                        = 1
        preWarmedInstanceCount                 = 0
        scmMinTlsVersion                       = "1.2"
        scmIpSecurityRestrictionsUseMain       = false
        scmIpSecurityRestrictionsDefaultAction = "Deny"
        use32BitWorkerProcess                  = true
        vnetRouteAllEnabled                    = true
        vnetPrivatePortsCount                  = 0
        webSocketsEnabled                      = false
        ipSecurityRestrictions = [
          {
            ipAddress   = "159.53.0.0/16"
            action      = "Allow"
            tag         = "Default"
            priority    = 400
            name        = "JPMCCIDR1"
            description = "JPMCCIDR1"
          },
          {
            ipAddress   = "146.143.0.0/16"
            action      = "Allow"
            tag         = "Default"
            priority    = 401
            name        = "JPMCCIDR2"
            description = "JPMCCIDR2"
          },
          {
            ipAddress   = "170.148.0.0/16"
            action      = "Allow"
            tag         = "Default"
            priority    = 402
            name        = "JPMCCIDR3"
            description = "JPMCCIDR3"
          },
          {
            ipAddress   = "103.246.196.0/23"
            action      = "Allow"
            tag         = "Default"
            priority    = 403
            name        = "JPMCCIDR4"
            description = "JPMCCIDR4"
          },
          {
            ipAddress   = "161.121.0.0/16"
            action      = "Allow"
            tag         = "Default"
            priority    = 404
            name        = "JPMCCIDR5"
            description = "JPMCCIDR5"
          },
          {
            ipAddress   = "Any"
            action      = "Deny"
            priority    = 2147483647
            name        = "Deny all"
            description = "Deny all access"
          }
        ]
      }
    }
  })
}

resource "azurerm_private_endpoint" "funcapp_endpoint" {
  name                = format("%s-%s", var.functionapp_name, "funcend")
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_pe_id

  private_service_connection {
    name                           = format("%s-%s", var.functionapp_name, "privateserviceconnection")
    private_connection_resource_id = azapi_resource.function_guardian.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

# resource "azurerm_role_assignment" "storage_account_blob_data_owner" {
#   scope                = data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Owner"
#   principal_id         = "3fddd566-7967-4b5e-a3b2-af13caac8d26" #SMI
# }

# resource "azurerm_role_assignment" "storage_account_blob_data_contributor" {
#   scope                = data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = "3fddd566-7967-4b5e-a3b2-af13caac8d26"
# }

# resource "azurerm_role_assignment" "event_hub_data_onwer" {
#   scope                = data.azurerm_eventhub_namespace.eventhub_ns.id
#   role_definition_name = "Azure Event Hubs Data Owner"
#   principal_id         = "3fddd566-7967-4b5e-a3b2-af13caac8d26"
# }

# resource "azurerm_role_assignment" "sbdc_to_human_user" {
#   scope                = data.azurerm_storage_account.storage_account.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = "874c6932-c62e-4452-97c2-5fa8932f2a4b" #SID
# }

# #give entitlements to GABS Dev and UAT SPNs to read ace guardian eventhub for testing
# resource "azurerm_role_assignment" "event_hub_data_onwer_spnuat" {
#   scope                = data.azurerm_eventhub_namespace.eventhub_ns.id
#   role_definition_name = "Azure Event Hubs Data Owner"
#   principal_id         = "270E906A-C969-43BE-BBC3-83235B782B8D"
# }

# resource "azurerm_role_assignment" "event_hub_data_onwer_spndev" {
#   scope                = data.azurerm_eventhub_namespace.eventhub_ns.id
#   role_definition_name = "Azure Event Hubs Data Owner"
#   principal_id         = "E3A4BCDD-34A1-451C-850A-621C2D55AF82"
# }

# #give entitlements to GABS Dev and UAT SPNs to read ace guardian service bus for testing
# resource "azurerm_role_assignment" "servicebus_data_onwer_spnuat" {
#   scope                = data.azurerm_servicebus_namespace.servicebus_ns.id
#   role_definition_name = "Azure Service Bus Data Owner"
#   principal_id         = "270E906A-C969-43BE-BBC3-83235B782B8D"
# }

# resource "azurerm_role_assignment" "servicebus_data_onwer_spndev" {
#   scope                = data.azurerm_servicebus_namespace.servicebus_ns.id
#   role_definition_name = "Azure Service Bus Data Owner"
#   principal_id         = "E3A4BCDD-34A1-451C-850A-621C2D55AF82"
# }

# resource "azurerm_role_assignment" "servicebus_data_owner_SID_W538083" {
#   scope                = data.azurerm_servicebus_namespace.servicebus_ns.id
#   role_definition_name = "Azure Service Bus Data Owner"
#   principal_id         = "931d2c6a-46c6-460a-8f15-b571f390a5fa"  #SID:W538083
# }