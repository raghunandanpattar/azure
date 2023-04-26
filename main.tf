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
resource "azurerm_resource_group" "Raghunandan" {
  name     = "Raghunandan"
  location = "West Europe"
  tags = {
    owner = "Raghu"
  }
}
resource "azurerm_storage_account" "s3bolte" {
  name = "s3bolte"
  resource_group_name = azurerm_resource_group.Raghunandan.name
  location = azurerm_resource_group.Raghunandan.location
  account_tier = "Standard"
  account_replication_type = "LRS"
  tags ={
    name = "storage-account"
  }
}
resource "azurerm_storage_container" "containerbolte" {
  name = "containerbolte"
  storage_account_name = "s3bolte"
  container_access_type = "blob"
}
resource "azurerm_storage_blob" "blobbolte" {
  name                   = "blobbolte.txt"
  storage_account_name   = azurerm_storage_account.s3bolte.name
  storage_container_name = azurerm_storage_container.containerbolte.name
  type                   = "Block"
  source                 = "blobbolte.txt"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "raghu-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Raghunandan.location
  resource_group_name = azurerm_resource_group.Raghunandan.name
}
resource "azurerm_subnet" "raghu-subnet" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.Raghunandan.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.Raghunandan.location
  resource_group_name = azurerm_resource_group.Raghunandan.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.raghu-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
    
  }
  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.public_ip
  ]
}
resource "azurerm_windows_virtual_machine" "wvm" {
  name                = "wvm"
  resource_group_name = azurerm_resource_group.Raghunandan.name
  location            = azurerm_resource_group.Raghunandan.location
  size                = "Standard_F2"
  admin_username      = "raghu"
  admin_password      = "Raghupattar_2504"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "public_ip" {

name = "public_ip"

location = azurerm_resource_group.Raghunandan.location

resource_group_name = azurerm_resource_group.Raghunandan.name

allocation_method = "Static"



}