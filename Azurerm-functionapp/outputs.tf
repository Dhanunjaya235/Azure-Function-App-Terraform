output "service_plan_id" {
  description = "ID of the App Service Plan when use_service_plan is true; null for consumption deployments."
  value       = var.use_service_plan ? azurerm_service_plan.service_plan[0].id : null
}

