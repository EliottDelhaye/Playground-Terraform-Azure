output "load_balancer_public_ip" {
    value       = azurerm_public_ip.pip_lb.ip_address
    description = "Public IP address of lb-1"
}