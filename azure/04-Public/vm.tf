# Public IP for the VM

resource "azurerm_public_ip" "public_ip" {
  name                = "jav-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# NSG

resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "YOUR PUBLIC ADDRESS"
    destination_address_prefix = "${azurerm_linux_virtual_machine.virtual_machine.public_ip_address}"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "virtual_machine" {
  disable_password_authentication = "false"
  name                  = "temporalvm"
  admin_username        = var.vmuser
  admin_password        = var.vmpassword
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-backports-gen2"
    version   = "latest"
  }
}

# Add SQL file to the VM

resource "null_resource" "add_files" {
 depends_on = [azurerm_mysql_flexible_database.main]
  # Remote connection to the virtual machine
  connection {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    type     = "ssh"
    user     = var.vmuser 
    password = var.vmpassword
    port     = 22
    timeout  = "10s"
  }

  provisioner "file" {
    source      = "./coches.sql"
    destination = "/home/${var.vmuser}/coches.sql"
  }

# Prepare my.cnf file for skip login in MYSQL

  provisioner "file" {
  content  = "[mysql]\nuser=${azurerm_mysql_flexible_server.default.administrator_login}\npassword=${azurerm_mysql_flexible_server.default.administrator_password}\n"
  destination = "/home/${var.vmuser}/.my.cnf"

}

}

# Install MYSQL and import the SQL file to the database "coches"

resource "null_resource" "mysql_install" {
 depends_on = [azurerm_mysql_flexible_server_configuration.default]
 # Remote connection to the virtual machine
  connection {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    type     = "ssh"
    user     = var.vmuser
    password = var.vmpassword
    port     = 22
    timeout  = "10s"
  }

  provisioner "remote-exec" {
      inline = [ "sudo apt update && sudo apt install default-mysql-server -y && mysql -h ${azurerm_mysql_flexible_server.default.name}.mysql.database.azure.com < /home/${var.vmuser}/coches.sql" ]
  }

}
