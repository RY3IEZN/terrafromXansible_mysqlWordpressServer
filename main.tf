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