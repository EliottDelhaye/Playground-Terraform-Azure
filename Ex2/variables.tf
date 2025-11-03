variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
}

variable "vm_username" {
  description = "Admin username for the virtual machine"
  type        = string
}

variable "vm_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true
}
