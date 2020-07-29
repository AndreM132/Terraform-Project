resource "azurerm_virtual_network" "resourcegroup1" {
  name                = "london-network"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.resource_group_location
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_linux_virtual_machine_scale_set" "resourcegroup1" {
  name                = "london-vm-scaleset"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  zones               = ["1", ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  lifecycle {
    ignore_changes = [instances, ]
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.internal.id
    }
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "london-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.resourcegroup1.id

  profile {
    name = "setup"

    capacity {
      default = 3
      minimum = 3
      maximum = 3
    }

    recurrence {
      timezone = "UTC"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [9]
      minutes  = [0]
    }
  }
  profile {
    name = "breakdown"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    recurrence {
      timezone = "UTC"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [17]
      minutes  = [0]
    }
  }

}
