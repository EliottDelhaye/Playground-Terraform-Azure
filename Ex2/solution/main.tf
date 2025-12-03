
############################
# Basic resources
############################

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    exercise = "Ex2"
  }
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}


############################
# NSG with 2 inbound rules:
# 1) AzureLoadBalancer -> TCP/80 (health probe)
# 2) Internet/Any     -> TCP/80 (trafic client)
############################
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_probe_from_AzureLoadBalancer_80"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
    description                = "Allow LB health probe & data path"
  }

  security_rule {
    name                       = "allow_internet_client_80"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    description                = "Allow client HTTP traffic to VMs"
  }
}

############################
# Public IP
############################
resource "azurerm_public_ip" "pip_lb" {
  name                = "pip-lb-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

############################
# Load Balancer public standard
############################
resource "azurerm_lb" "lb" {
  name                = var.load_balancer_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-fe"
    public_ip_address_id = azurerm_public_ip.pip_lb.id
  }
}

# Backend pool
resource "azurerm_lb_backend_address_pool" "be" {
  name            = "lb-be"
  loadbalancer_id = azurerm_lb.lb.id
}

# Probe TCP 80
resource "azurerm_lb_probe" "probe80" {
  name                = "probe-80"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Load balancing rule 80 -> 80 (TCP)
resource "azurerm_lb_rule" "http80" {
  name                           = "rule-http-80"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-fe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.be.id]
  probe_id                       = azurerm_lb_probe.probe80.id
  idle_timeout_in_minutes        = 4
  disable_outbound_snat          = true
}

#  Outbound rule to provide Internet connectivity for VMs (apt, etc.)
resource "azurerm_lb_outbound_rule" "out" {
  name                    = "outbound-vms"
  loadbalancer_id         = azurerm_lb.lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be.id
  allocated_outbound_ports = 1024

  frontend_ip_configuration {
    name = "lb-fe"
  }
}


############################
# NICs for the VMs with static private IPs
############################
resource "azurerm_network_interface" "nic1" {
  name                = "nic-vm-1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "nic-vm-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.5"
  }
}

# Associate the NSG with the NICs
resource "azurerm_network_interface_security_group_association" "nsg_nic1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "nsg_nic2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Associate the NICs with the backend pool of the LB
resource "azurerm_network_interface_backend_address_pool_association" "be_nic1" {
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be.id
}

resource "azurerm_network_interface_backend_address_pool_association" "be_nic2" {
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.be.id
}


############################
# Nginx with HTML page
############################
locals {
  cloud_init = <<-YAML
  #cloud-config
  package_update: true
  packages:
    - nginx
  runcmd:
    - IP_PRIV=$(hostname -I | awk '{print $1}')
    - |
      cat >/var/www/html/index.html <<'HTML'
      <!DOCTYPE html>
      <html>
      <head><meta charset="utf-8"><title>LB Lab</title></head>
      <body style="font-family:Arial; text-align:center; margin-top:10%;">
        <h1>Azure LB Lab</h1>
        <h2>Private IP: __IP__</h2>
      </body>
      </html>
      HTML
    - sed -i "s/__IP__/$${IP_PRIV}/g" /var/www/html/index.html
    - systemctl enable nginx
    - systemctl restart nginx
  YAML
}


############################
# Linux Virtual Machines
############################

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "VM-1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size

  admin_username                  = var.vm_username
  disable_password_authentication = "false"
  admin_password                  = var.vm_password

  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  custom_data = base64encode(local.cloud_init)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

}

resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "VM-2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size

  admin_username                  = var.vm_username
  disable_password_authentication = "false"
  admin_password                  = var.vm_password

  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]

  custom_data = base64encode(local.cloud_init)

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

}
