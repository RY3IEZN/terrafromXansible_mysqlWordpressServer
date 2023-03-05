# create the VM
resource "azurerm_linux_virtual_machine" "poc_fe_vm" {
  name                = "pocFeVm"
  resource_group_name = azurerm_resource_group.poc_server_rg.name
  location            = azurerm_resource_group.poc_server_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.poc-nic1.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  provisioner "local-exec" {
    working_dir = "/home/ubuntu/teraaformxansible/terrafromXansible_mysqlWordpressServer"
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook deploy_wordpress.yaml -i ${self.public_ip_address}, --private-key ${var.ssh_key} --user adminuser"
  }


  tags = {
    enviroment : "dev"
  }

}
