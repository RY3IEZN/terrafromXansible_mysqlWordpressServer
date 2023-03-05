terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# create a resource group
resource "azurerm_resource_group" "poc_server_rg" {
  name     = "poc_server_rg"
  location = "Uk South"

  tags = {
    enviroment : "stage0"
  }
}

#create a virtual netowrk
resource "azurerm_virtual_network" "poc_server_vn" {
  name                = "poc_server_vn"
  location            = azurerm_resource_group.poc_server_rg.location
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    enviroment : "stage0"
  }
}

#create Subnet1 for frontend
resource "azurerm_subnet" "poc_server_subnet1" {
  name                 = "wordpress_subnet"
  resource_group_name  = azurerm_resource_group.poc_server_rg.name
  virtual_network_name = azurerm_virtual_network.poc_server_vn.name
  address_prefixes     = ["10.0.1.0/24"]
}

#create Subnet2 for backend
resource "azurerm_subnet" "poc_server_subnet2" {
  name                 = "database_subnet"
  resource_group_name  = azurerm_resource_group.poc_server_rg.name
  virtual_network_name = azurerm_virtual_network.poc_server_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

# create the storage account for imgs
resource "azurerm_storage_account" "poc_storage" {
  name                     = "pocstoragesz"
  resource_group_name      = azurerm_resource_group.poc_server_rg.name
  location                 = azurerm_resource_group.poc_server_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "stage0"
  }
}

# create NSG 
resource "azurerm_network_security_group" "poc_nsg" {
  name                = "poc_nsg"
  location            = azurerm_resource_group.poc_server_rg.location
  resource_group_name = azurerm_resource_group.poc_server_rg.name
}

# associate to the 2 subnets
resource "azurerm_subnet_network_security_group_association" "poc_nsg_asoc1" {
  subnet_id                 = azurerm_subnet.poc_server_subnet1.id
  network_security_group_id = azurerm_network_security_group.poc_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "poc_nsg_asoc2" {
  subnet_id                 = azurerm_subnet.poc_server_subnet2.id
  network_security_group_id = azurerm_network_security_group.poc_nsg.id
}

# # create the rules for the nsg
# resource "azurerm_network_security_rule" "poc_nsg_rule1" {
#   name                        = "poc_nsg_rule1"
#   priority                    = 201
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "22"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.poc_server_rg.name
#   network_security_group_name = azurerm_network_security_group.poc_nsg.name
# }
# create the rules for the nsg
resource "azurerm_network_security_rule" "poc_nsg_rule2" {
  name                        = "poc_nsg_rule2"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.poc_server_rg.name
  network_security_group_name = azurerm_network_security_group.poc_nsg.name
}

# create a public IP for the vm
resource "azurerm_public_ip" "poc-server-ip1" {
  name                = "poc-server-ip1"
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  location            = azurerm_resource_group.poc_server_rg.location
  allocation_method   = "Dynamic"
  # sku = "Standard"

  tags = {
    environment = "stage0"
  }
}
# create a public IP for the vm2
resource "azurerm_public_ip" "poc-server-ip2" {
  name                = "poc-server-ip2"
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  location            = azurerm_resource_group.poc_server_rg.location
  allocation_method   = "Dynamic"
  # sku = "Standard"

  tags = {
    environment = "stage0"
  }
}

// create a NIC for the vm
resource "azurerm_network_interface" "poc-nic1" {
  name                = "poc-nic1"
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  location            = azurerm_resource_group.poc_server_rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.poc_server_subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.poc-server-ip1.id
  }

  tags = {
    enviroment : "stage0"
  }
}
// create a NIC for the vm2
resource "azurerm_network_interface" "poc-nic2" {
  name                = "poc-nic2"
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  location            = azurerm_resource_group.poc_server_rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.poc_server_subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.poc-server-ip2.id
  }

  tags = {
    enviroment : "stage0"
  }
}

