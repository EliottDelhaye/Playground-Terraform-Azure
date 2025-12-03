resource "azurerm_resource_group" "rg-app-01" {
  name     = "rg-ex03"
  location = var.location
}

// VNET-HUB

resource "azurerm_virtual_network" "vnet-hub" {
  name                = "vnet-hub"
  resource_group_name = azurerm_resource_group.rg-app-01.name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
}

resource "azurerm_subnet" "subnet-hub-01" {
  name                 = "subnet-hub-01"
  resource_group_name  = azurerm_resource_group.rg-app-01.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_linux_virtual_machine" "vm-client" {
  name                            = "vm-client"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-client.id]
  size                            = "Standard_B1ms"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_network_interface" "nic-client" {
  name                = "nic-client"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-hub-01.id
    private_ip_address_allocation = "Dynamic"
  }
}

// VNET-SPOKE

resource "azurerm_virtual_network" "vnet-spoke" {
  name                = "vnet-spoke"
  resource_group_name = azurerm_resource_group.rg-app-01.name
  address_space       = ["10.1.0.0/16"]
  location            = var.location
}

resource "azurerm_subnet" "subnet-spoke-01" {
  name                            = "subnet-spoke-01"
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  virtual_network_name            = azurerm_virtual_network.vnet-spoke.name
  address_prefixes                = ["10.1.0.0/24"]
  default_outbound_access_enabled = true
}

resource "azurerm_linux_virtual_machine" "vm-app-i01" {
  name                            = "vm-app-i01"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-app-i01.id]
  size                            = "Standard_B1ms"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(<<-EOF
     #!/bin/bash
     apt-get update
     apt-get upgrade -y
     apt-get install -y nginx
     echo "VM1" > /var/www/html/index.html
     systemctl restart nginx
     EOF
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_network_interface" "nic-app-i01" {
  name                = "nic-app-i01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm-app-i02" {
  name                            = "vm-app-i02"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-app-i02.id]
  size                            = "Standard_B1ms"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(<<-EOF
     #!/bin/bash
     apt-get update
     apt-get upgrade -y
     apt-get install -y nginx
     echo "VM2" > /var/www/html/index.html
     systemctl restart nginx
     EOF
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  boot_diagnostics {}
}

resource "azurerm_network_interface" "nic-app-i02" {
  name                = "nic-app-i02"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet-spoke-01.id
    private_ip_address_allocation = "Dynamic"
  }
}

/// Load Balancer

resource "azurerm_lb" "lb-spoke" {
  name                = "lb-spoke"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "fp-ip"
    subnet_id                     = azurerm_subnet.subnet-spoke-01.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_linux_virtual_machine.vm-app-i01,
    azurerm_linux_virtual_machine.vm-app-i02
  ]
}

resource "azurerm_lb_backend_address_pool" "lb-backend-pool" {
  loadbalancer_id = azurerm_lb.lb-spoke.id
  name            = "backend-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-app-i01-association" {
  network_interface_id    = azurerm_network_interface.nic-app-i01.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend-pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic-app-i02-association" {
  network_interface_id    = azurerm_network_interface.nic-app-i02.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-backend-pool.id
}

resource "azurerm_lb_probe" "lb-probe" {
  loadbalancer_id = azurerm_lb.lb-spoke.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "lb-rule" {
  loadbalancer_id                = azurerm_lb.lb-spoke.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fp-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend-pool.id]
  probe_id                       = azurerm_lb_probe.lb-probe.id
}

// VNET peering

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = azurerm_resource_group.rg-app-01.name
  virtual_network_name      = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-spoke.id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = azurerm_resource_group.rg-app-01.name
  virtual_network_name      = azurerm_virtual_network.vnet-spoke.name
  remote_virtual_network_id = azurerm_virtual_network.vnet-hub.id
}

// Application Security Group

resource "azurerm_application_security_group" "asg-spoke-01" {
  name                = "asg-spoke-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name
}

resource "azurerm_network_interface_application_security_group_association" "app-i01" {
  application_security_group_id = azurerm_application_security_group.asg-spoke-01.id
  network_interface_id          = azurerm_network_interface.nic-app-i01.id
}

resource "azurerm_network_interface_application_security_group_association" "app-i02" {
  application_security_group_id = azurerm_application_security_group.asg-spoke-01.id
  network_interface_id          = azurerm_network_interface.nic-app-i02.id
}

// Network Security Group

resource "azurerm_network_security_group" "nsg-spoke-01" {
  name                = "nsg-spoke-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name
}

resource "azurerm_network_security_rule" "allow-internet" {
  name                        = "allow-internet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.rg-app-01.name
  network_security_group_name = azurerm_network_security_group.nsg-spoke-01.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-subnet-association" {
  subnet_id                 = azurerm_subnet.subnet-spoke-01.id
  network_security_group_id = azurerm_network_security_group.nsg-spoke-01.id
}

// NAT Gateway

resource "azurerm_nat_gateway" "nat-gateway-01" {
  name                    = "nat-gateway-01"
  location                = var.location
  resource_group_name     = azurerm_resource_group.rg-app-01.name
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

resource "azurerm_subnet_nat_gateway_association" "nat-gateway-subnet-association-01" {
  subnet_id      = azurerm_subnet.subnet-spoke-01.id
  nat_gateway_id = azurerm_nat_gateway.nat-gateway-01.id
}

resource "azurerm_public_ip" "pip-spoke-01" {
  name                = "pip-spoke-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-app-01.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "nat-gateway-pip-association-01" {
  nat_gateway_id       = azurerm_nat_gateway.nat-gateway-01.id
  public_ip_address_id = azurerm_public_ip.pip-spoke-01.id
}
