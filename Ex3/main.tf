resource "azurerm_resource_group" "rg-app-01" {
  name     = "rg-app-01"
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

resource "azurerm_linux_virtual_machine" "vm-client" {
  name                            = "vm-client"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-client.id]
  size                            = "Standard_B1ms"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
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

resource "azurerm_linux_virtual_machine" "vm-app-i01" {
  name                            = "vm-app-i01"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-app-i01.id]
  size                            = "Standard_B1ms"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

    # custom_data = base64encode(<<-EOF
  #   #!/bin/bash
  #   apt-get update
  #   apt-get upgrade -y
  #   apt-get install -y nginx
  #   echo "VM1" > /var/www/html/index.html
  #   systemctl restart nginx
  #   EOF
  # )

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

resource "azurerm_linux_virtual_machine" "vm-app-i02" {
  name                            = "vm-app-i02"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.rg-app-01.name
  network_interface_ids           = [azurerm_network_interface.nic-app-i02.id]
  size                            = "Standard_B1ms"
  admin_username                  = "azureuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  # custom_data = base64encode(<<-EOF
  #   #!/bin/bash
  #   apt-get update
  #   apt-get upgrade -y
  #   apt-get install -y nginx
  #   echo "VM1" > /var/www/html/index.html
  #   systemctl restart nginx
  #   EOF
  # )

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