terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.53.0"
    }
  }
}
provider "azurerm" {
  client_id = "0b81042b-5ed1-4e69-8906-4275550430c3"
  client_secret = "gOC8Q~jmT5WfhHJx~JN5ScvjuIa1-7G1FZhx9diu"
  tenant_id = "7d3584f0-35e1-4d32-9418-8e9461a6bb53"
  subscription_id = "0cf986a3-a795-4a6e-94fd-2eeef4ddc321"
  features {}   
}
resource "azurerm_resource_group" "Rgnpattar" {
  name     = "Rgnpattar"
  location = "West Europe"
  tags = {
    owner = "Raghu"
  }
}
resource "azurerm_storage_account" "ssaavvmm" {
  name = "ssaavvmm"
  resource_group_name = azurerm_resource_group.Rgnpattar.name
  location = azurerm_resource_group.Rgnpattar.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  tags ={
    name = "storage-account-vm"
  }
}
resource "azurerm_virtual_network" "vvnn" {
  name                = "vvnn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Rgnpattar.location
  resource_group_name = azurerm_resource_group.Rgnpattar.name
}
resource "azurerm_subnet" "rasn" {
  name                 = "rasn"
  resource_group_name  = azurerm_resource_group.Rgnpattar.name
  virtual_network_name = azurerm_virtual_network.vvnn.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "nniicc" {
  name                = "nniicc"
  location            = azurerm_resource_group.Rgnpattar.location
  resource_group_name = azurerm_resource_group.Rgnpattar.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.rasn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
    
  }
  depends_on = [
    azurerm_virtual_network.vvnn,
    azurerm_public_ip.public_ip
  ]
}
resource "azurerm_linux_virtual_machine" "lnxvm" {
  name                = "lnxvm"
  resource_group_name = azurerm_resource_group.Rgnpattar.name
  location            = azurerm_resource_group.Rgnpattar.location
  size                = "Standard_F2"
  admin_username      = "raghu"
  admin_password      = "Raghupattar_2504"
  network_interface_ids = [
    azurerm_network_interface.nniicc.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "public_ip" {
  name = "public_ip"
  location = azurerm_resource_group.Rgnpattar.location
  resource_group_name = azurerm_resource_group.Rgnpattar.name
  allocation_method = "Static"
}
