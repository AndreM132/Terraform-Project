provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resourcegroup1" {
  name     = "terraform-rg"
  location = "uksouth"
}

module "london" {
  source                  = "./development_uks"
  resource_group_location = "uksouth"
  resource_group_name     = azurerm_resource_group.resourcegroup1.name
}

module "paris" {
  source                  = "./production_we"
  resource_group_location = "West Europe"
  resource_group_name     = azurerm_resource_group.resourcegroup1.name
}

module "mumbai" {
  source                  = "./staging_ea"
  resource_group_location = "East Asia"
  resource_group_name     = azurerm_resource_group.resourcegroup1.name
}
