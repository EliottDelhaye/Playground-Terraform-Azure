output "lb-ip" {
  value = azurerm_lb.lb-spoke.frontend_ip_configuration[0].private_ip_address
}