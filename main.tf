resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.location
}
#Create Virtual Network
resource "azurerm_virtual_network" "vnet-service" {
  name = var.virtual_network
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = ["10.10.0.0/16"]
 }
  
#Creating Subnet
  resource "azurerm_subnet" "snet-service" {
  name                 = var.subnet1
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-service.name
  address_prefixes     = ["10.10.0.0/26"]
}
#Network Security Group
  resource "azurerm_network_security_group" "nsg" {
    name = var.network_security_group
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
  }

#NIC
resource "azurerm_network_interface" "nic" {
  name                = "random-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     = azurerm_subnet.snet-service.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic1" {
  name                = "value-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfiguration2"
    subnet_id                     = azurerm_subnet.snet-service.id
    private_ip_address_allocation = "Dynamic"
  }
}

#VM1 Creation 
resource "azurerm_virtual_machine" "VM1" {
  name                  = var.virtual_machine1
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1ms"

  # Comment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Comment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname1"
    admin_username = "testadmin1"
    admin_password = "Password12345!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "dev"
  }
}

#VM2 creation
resource "azurerm_virtual_machine" "VM2" {
  name                  = var.virtual_machine2
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic1.id]
  vm_size               = "Standard_B1ms"

  # Comment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = true

  # Comment this line to delete the data disks automatically when deleting the VM
   delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "dev"
  }
}
