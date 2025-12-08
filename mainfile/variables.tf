variable "environment" {
  description = "Environment to which this configuration is deployed"
  type        = string
  default     = "dev3"
}

variable "application_name" {
  description = "Application name (e.g., ace-guardian, ace-compliance-engine)"
  type        = string
  default     = "ace-guardian"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region where resources will be deployed"
}

variable "storage_account_name" {
  type        = string
  description = "Storage Account Name for Function App"
  default     = ""
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

variable "use_service_plan" {
  type        = bool
  description = "Set to true to deploy the Function App on a dedicated/premium App Service Plan. Defaults to false for Consumption plan."
  default     = false
}


variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for Application Insights"
  default     = ""
}
