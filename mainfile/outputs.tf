output "umi_id" {
  value       = azurerm_user_assigned_identity.umi.id
  description = "Resource ID of the user-assigned managed identity"
}

output "umi_client_id" {
  value       = azurerm_user_assigned_identity.umi.client_id
  description = "Client ID of the user-assigned managed identity"
}

