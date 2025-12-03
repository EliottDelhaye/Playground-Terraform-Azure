output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer"
  value       = azurerm_public_ip.pip_lb.ip_address
}

output "load_balancer_name" {
  description = "Name of the Load Balancer"
  value       = azurerm_lb.lb.name
}

output "vm1_private_ip" {
  description = "Private IP address of VM-1"
  value       = azurerm_network_interface.nic1.private_ip_address
}

output "vm2_private_ip" {
  description = "Private IP address of VM-2"
  value       = azurerm_network_interface.nic2.private_ip_address
}

output "test_url" {
  description = "URL to test the Load Balancer"
  value       = "http://${azurerm_public_ip.pip_lb.ip_address}"
}