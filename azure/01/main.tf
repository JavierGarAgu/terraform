# Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${var.resource_group_name}-rg"
}

# Virtual Network
resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Network Security Group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
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
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect Network Security Group to the Network Interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "virtual_machine" {
  disable_password_authentication = "false"
  name                  = "${var.prefix}-vm"
  admin_username        = "${var.user}"
  admin_password        = "${var.password}"
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

# Install nginx to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  name                       = "${var.prefix}-wsi"
  virtual_machine_id         = azurerm_linux_virtual_machine.virtual_machine.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  protected_settings = <<PROT
    {
        "script": "${base64encode(file(var.install))}"
    }
  PROT
}

# Null Resource for remote execution on the VM
resource "null_resource" "get_nginx_status" {
  depends_on = [azurerm_virtual_machine_extension.web_server_install]

  # Remote connection to the virtual machine
  connection {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    type     = "ssh"
    user     = "${var.user}"
    password = "${var.password}"
    port     = 22
    timeout  = "10s"
  }

  provisioner "remote-exec" {
    script = var.output
  }
 
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /var/www/html"
      # Temporary remote-exec to set chmod 777 on /var/www/html for add files.
      # In the subsequent remote-exec block, the permissions will be reset to their original state.
   ]
  }
}

# Null Resource for transferring files to the VM
resource "null_resource" "add_files" {
  depends_on = [null_resource.get_nginx_status]

  # Remote connection to the virtual machine
  connection {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    type     = "ssh"
    user     = "${var.user}"
    password = "${var.password}"
    port     = 22
    timeout  = "10s"
  }

  provisioner "file" {
    source      = "./html"
    destination = "/var/www"
  }
}

resource "null_resource" "remove_permissions" {
  depends_on = [null_resource.add_files]

  # Remote connection to the virtual machine
  connection {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    type     = "ssh"
    user     = "${var.user}"
    password = "${var.password}"
    port     = 22
    timeout  = "10s"
  }

provisioner "remote-exec" {
  inline = [
    "sudo chmod 755 /var/www/html"
    # Resetting the permissions to 755 on /var/www/html.
    # The chmod command sets the permissions to read, write, and execute for the owner, and read and execute for the group and others.
    # This is more restrictive than the previous 777 setting, ensuring better security after the provisioning tasks are done.
  ]
}
}

# Data Source to retrieve Nginx status from the VM
data "remotefile" "nginx_status" {
  depends_on = [null_resource.get_nginx_status]
  conn {
    host     = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
    port     = 22
    username = "${var.user}"
    password = "${var.password}"
  }
  path = "/tmp/nginx.json"
}
