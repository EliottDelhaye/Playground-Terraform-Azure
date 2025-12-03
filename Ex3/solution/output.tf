output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg-app-01.name
}

output "lb_internal_private_ip" {
  description = "Private IP address of the internal Load Balancer"
  value       = azurerm_lb.lb-spoke.frontend_ip_configuration[0].private_ip_address
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = azurerm_public_ip.pip-spoke-01.ip_address
}

output "vnet_hub_id" {
  description = "ID of the Hub VNet"
  value       = azurerm_virtual_network.vnet-hub.id
}

output "vnet_spoke_id" {
  description = "ID of the Spoke VNet"
  value       = azurerm_virtual_network.vnet-spoke.id
}

output "vm_client_private_ip" {
  description = "Private IP address of the client VM in Hub VNet"
  value       = azurerm_network_interface.nic-client.private_ip_address
}

output "vm_app_i01_private_ip" {
  description = "Private IP address of VM-APP-I01 in Spoke VNet"
  value       = azurerm_network_interface.nic-app-i01.private_ip_address
}

output "vm_app_i02_private_ip" {
  description = "Private IP address of VM-APP-I02 in Spoke VNet"
  value       = azurerm_network_interface.nic-app-i02.private_ip_address
}

output "test_command" {
  description = "Command to test the internal Load Balancer from vm-client"
  value       = "curl http://${azurerm_lb.lb-spoke.frontend_ip_configuration[0].private_ip_address}"
}

output "summary" {
  description = "Deployment summary and test instructions"
  value = <<-EOT
  
  ✅ Deployment successful!
  
  Hub VNet (10.0.0.0/16)
    └─ VM-Client: ${azurerm_network_interface.nic-client.private_ip_address}
  
  Spoke VNet (10.1.0.0/16)
    ├─ VM-APP-I01: ${azurerm_network_interface.nic-app-i01.private_ip_address}
    ├─ VM-APP-I02: ${azurerm_network_interface.nic-app-i02.private_ip_address}
    └─ Internal LB: ${azurerm_lb.lb-spoke.frontend_ip_configuration[0].private_ip_address}
  
  🧪 Test from Azure Portal:
  1. Connect to vm-client via Serial Console or Bastion
  2. Run: curl http://${azurerm_lb.lb-spoke.frontend_ip_configuration[0].private_ip_address}
  3. Expected: "VM1" or "VM2" (load balanced)
  
  💡 The internal LB is only accessible from Hub VNet via VNet peering
  EOT
}