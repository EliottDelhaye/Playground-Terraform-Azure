output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_private_ip" {
  description = "Private IP address of the virtual machine"
  value       = azurerm_network_interface.interface.private_ip_address
}

output "summary" {
  description = "Deployment summary"
  value = <<-EOT
  
  ✅ Deployment successful!
  
  Resource Group: ${azurerm_resource_group.rg.name}
  Location: ${azurerm_resource_group.rg.location}
  VM Name: ${azurerm_linux_virtual_machine.vm.name}
  Private IP: ${azurerm_network_interface.interface.private_ip_address}
  
  ⚠️  No public IP - VM is only accessible within the VNet
  💡 To connect, deploy Azure Bastion or use Serial Console in Azure Portal
  EOT
}
