terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "monitoring" {
#   name     = var.resource_group_name
#   location = var.location
# }

resource "azurerm_virtual_network" "monitoring" {
  name                = "monitoring-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "monitoring" {
  name                 = "monitoring-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.monitoring.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "monitoring" {
  name                = "monitoring-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "monitoring" {
  name                = "monitoring-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name


  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  # # Prometheus
  # security_rule {
  #   name                       = "Prometheus"
  #   priority                   = 1002
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "9090"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # # Grafana
  # security_rule {
  #   name                       = "Grafana"
  #   priority                   = 1003
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "3000"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # # Node Exporter
  # security_rule {
  #   name                       = "NodeExporter"
  #   priority                   = 1004
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "9100"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # # Blackbox Exporter
  # security_rule {
  #   name                       = "BlackboxExporter"
  #   priority                   = 1005
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "9115"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # # Alertmanager
  # security_rule {
  #   name                       = "Alertmanager"
  #   priority                   = 1006
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "9093"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }

  # # Test App
  # security_rule {
  #   name                       = "NodeApp"
  #   priority                   = 1007
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "3001"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
}

resource "azurerm_network_interface" "monitoring" {
  name                = "monitoring-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.monitoring.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.monitoring.id
  }
}

resource "azurerm_network_interface_security_group_association" "monitoring" {
  network_interface_id      = azurerm_network_interface.monitoring.id
  network_security_group_id = azurerm_network_security_group.monitoring.id
}

resource "azurerm_linux_virtual_machine" "monitoring" {
  name                            = "monitoring-vm"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.monitoring.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}
//---------------

# resource "azurerm_virtual_network" "main" {
#   name                = var.vnet_name
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "internal" {
#   name                 = "internal"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = ["10.0.1.0/24"]
# }
# resource "azurerm_network_security_group" "nsg" {
#   name                = "monitoring-nsg"
#   location            = var.location
#   resource_group_name = var.resource_group_name
# }

# resource "azurerm_network_security_rule" "allow_ssh" {
#   name                        = "Allow-SSH"
#   priority                    = 1001
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.nsg.name
# }

# resource "azurerm_network_security_rule" "allow_blackbox" {
#   name                        = "Allow-Blackbox"
#   priority                    = 1002
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "9115"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = var.resource_group_name
#   network_security_group_name = azurerm_network_security_group.nsg.name
# }
# resource "azurerm_public_ip" "vm_ip" {
#   name                = "vm-ip"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   allocation_method   = "Static"
# }

# resource "azurerm_network_interface" "vm_nic" {
#   name                = "vm-nic"
#   location            = var.location
#   resource_group_name = var.resource_group_name

#   ip_configuration {
#     name                          = "vm-ip-config"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.vm_ip.id
#   }
# }

# resource "azurerm_linux_virtual_machine" "monitoring_vm" {
#   name                            = "monitoring-vm"
#   resource_group_name             = var.resource_group_name
#   location                        = var.location
#   size                            = "Standard_B2s"
#   admin_username                  = var.admin_username
#   admin_password                  = var.admin_password # Change this!
#   disable_password_authentication = false

#   network_interface_ids = [azurerm_network_interface.vm_nic.id]

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "ubuntu-24_04-lts"
#     sku       = "server"
#     version   = "latest"
#   }
# }
