variable "name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The Azure Region where the Resource Group should exist"
  default     = "eastus"
}

variable "tags" {
  type        = map(any)
  description = "A mapping of tags which should be assigned to the Resource Group."
}