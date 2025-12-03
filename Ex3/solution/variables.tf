variable "subscription_id" {
  description = "The Subscription ID where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "admin_username" {
  description = "Admin username for virtual machines."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for virtual machines."
  type        = string
  sensitive   = true
}