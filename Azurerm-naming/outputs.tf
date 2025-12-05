locals {
  resource_name         = "${var.application_name_map[var.application_name]}-${var.location_map[var.location]}-${var.environment_map[var.environment]}-${var.resource_type_map[var.resource_type]}"
  resource_name_prepend = "${var.application_name_map[var.application_name]}-${var.location_map[var.location]}-${var.environment_map[var.environment]}"
  resource_name_append  = "${var.resource_type_map[var.resource_type]}"

  sa_name               = lower(replace(local.resource_name, "-", ""))
  sa_name_prepend       = lower(replace(local.resource_name_prepend, "-", ""))
  sa_name_append        = lower(replace(local.resource_name_append, "-", ""))
  name                  = var.resource_type == "storage_account" ? local.sa_name : local.resource_name
}

output "name" {
  value       = local.name
  description = "Name of the resource"
}

output "name_append" {
  value       = local.resource_name_append
  description = "Name of the resource that was appended"
}

output "name_prepend" {
  value       = local.resource_name_prepend
  description = "Name of the resource that was prepended"
}

output "sa_name" {
  value = local.sa_name
  description = "Value if resource was a storage account"
}