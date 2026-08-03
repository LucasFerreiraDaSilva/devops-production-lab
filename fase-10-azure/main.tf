terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "devops_lab" {
  name     = "rg-devops-lab"
  location = "East US"
}

resource "azurerm_virtual_network" "devops_lab_vnet" {
  name                = "vnet-devops-lab"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.devops_lab.location
  resource_group_name = azurerm_resource_group.devops_lab.name
}

resource "azurerm_subnet" "devops_lab_subnet" {
  name                 = "subnet-devops-lab"
  resource_group_name  = azurerm_resource_group.devops_lab.name
  virtual_network_name = azurerm_virtual_network.devops_lab_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "devops_lab_ip" {
  name                = "pip-devops-lab"
  resource_group_name = azurerm_resource_group.devops_lab.name
  location            = azurerm_resource_group.devops_lab.location
  allocation_method   = "Static"
  sku		      = "Standard"
}

resource "azurerm_network_security_group" "devops_lab_nsg" {
  name                = "nsg-devops-lab"
  location            = azurerm_resource_group.devops_lab.location
  resource_group_name = azurerm_resource_group.devops_lab.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "devops_lab_nic" {
  name                = "nic-devops-lab"
  location            = azurerm_resource_group.devops_lab.location
  resource_group_name = azurerm_resource_group.devops_lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devops_lab_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops_lab_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "devops_lab_nic_nsg" {
  network_interface_id      = azurerm_network_interface.devops_lab_nic.id
  network_security_group_id = azurerm_network_security_group.devops_lab_nsg.id
}

resource "azurerm_linux_virtual_machine" "devops_lab_vm" {
  name                = "vm-devops-lab"
  resource_group_name = azurerm_resource_group.devops_lab.name
  location            = azurerm_resource_group.devops_lab.location
  size                = "Standard_D2ads_v7"
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.devops_lab_nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/azure-devops-lab-rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
