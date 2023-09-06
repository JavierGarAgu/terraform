# Resource Group Creation
resource "azurerm_resource_group" "test" {
  name     = "acctestrg"
  location = "West US 2"
}

# Virtual Network Creation
resource "azurerm_virtual_network" "test" {
  name                = "acctvn"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

# Subnet Creation
resource "azurerm_subnet" "test" {
  name                 = "acctsub"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Public IP Creation
resource "azurerm_public_ip" "test" {
  name                         = "publicIPForLB"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  allocation_method            = "Static"
}

# Load Balancer Creation
resource "azurerm_lb" "test" {
  name                = "loadBalancer"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

# Backend Address Pool Creation
resource "azurerm_lb_backend_address_pool" "test" {
  loadbalancer_id     = azurerm_lb.test.id
  name                = "BackEndAddressPool"
}

# NAT Rule Creation for Load Balancer
resource "azurerm_lb_nat_rule" "test1" {
  name                           = "ssh-1022-vm-22"
  protocol                       = "Tcp"
  frontend_port                  = 1022
  backend_port                   = 22
  frontend_ip_configuration_name = "publicIPAddress"
  resource_group_name            = azurerm_resource_group.test.name
  loadbalancer_id                = azurerm_lb.test.id
}

# Network Interface Association with LB NAT Rule
resource "azurerm_network_interface_nat_rule_association" "test1" {
  network_interface_id      = azurerm_network_interface.test.*.id[0]
  ip_configuration_name     = "testConfiguration"
  nat_rule_id               = azurerm_lb_nat_rule.test1.id
}

# NAT Rule Creation for Load Balancer (Additional Rules)
resource "azurerm_lb_nat_rule" "test2" {
  name                           = "ssh-2022-vm-22"
  protocol                       = "Tcp"
  frontend_port                  = 2022
  backend_port                   = 22
  frontend_ip_configuration_name = "publicIPAddress"
  resource_group_name            = azurerm_resource_group.test.name
  loadbalancer_id                = azurerm_lb.test.id
}

resource "azurerm_network_interface_nat_rule_association" "test2" {
  network_interface_id      = azurerm_network_interface.test.*.id[1]
  ip_configuration_name     = "testConfiguration"
  nat_rule_id               = azurerm_lb_nat_rule.test2.id
}

resource "azurerm_lb_nat_rule" "test3" {
  name                           = "ssh-3022-vm-22"
  protocol                       = "Tcp"
  frontend_port                  = 3022
  backend_port                   = 22
  frontend_ip_configuration_name = "publicIPAddress"
  resource_group_name            = azurerm_resource_group.test.name
  loadbalancer_id                = azurerm_lb.test.id
}

resource "azurerm_network_interface_nat_rule_association" "test3" {
  network_interface_id      = azurerm_network_interface.test.*.id[2]
  ip_configuration_name     = "testConfiguration"
  nat_rule_id               = azurerm_lb_nat_rule.test3.id
}

# Probe Creation for Load Balancer
resource "azurerm_lb_probe" "web" {
  loadbalancer_id = azurerm_lb.test.id
  name            = "web"
  port            = 80
}

# Load Balancer Rule Creation
resource "azurerm_lb_rule" "test" {
  loadbalancer_id            = azurerm_lb.test.id
  name                       = "web"
  protocol                   = "Tcp"
  frontend_port              = 80
  backend_port               = 80
  frontend_ip_configuration_name = "publicIPAddress"
  probe_id                   = azurerm_lb_probe.web.id
  backend_address_pool_ids   = [azurerm_lb_backend_address_pool.test.id]
}

# Automated Backend Pool Addition (Associating NICs to Backend Pool)
resource "azurerm_network_interface_backend_address_pool_association" "business-tier-pool" {
  count = 3
  network_interface_id    = azurerm_network_interface.test.*.id[count.index]
  ip_configuration_name   = "testConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.test.id
}

# Network Interface Creation
resource "azurerm_network_interface" "test" {
  count               = 3
  name                = "acctni${count.index}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Availability Set Creation
resource "azurerm_availability_set" "avset" {
  name                         = "avset"
  location                     = azurerm_resource_group.test.location
  resource_group_name          = azurerm_resource_group.test.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
  managed                      = true
}

# Linux Virtual Machine Creation
resource "azurerm_linux_virtual_machine" "test" {
  count               = 3
  name                = "acctvm${count.index}"
  location            = azurerm_resource_group.test.location
  availability_set_id = azurerm_availability_set.avset.id
  resource_group_name = azurerm_resource_group.test.name
  network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
  size                = "Standard_B1s"
  admin_username        = "testadmin"
  admin_password        = "Password1234!"
  disable_password_authentication = false

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

# Virtual Machine Extension (Installation of Nginx)
resource "azurerm_virtual_machine_extension" "web_server_install" {
  count = 3
  name                       = "webserver_extension_${count.index}"
  virtual_machine_id         = azurerm_linux_virtual_machine.test[count.index].id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
 {
  "commandToExecute": "sudo apt update && sudo apt-get install nginx -y && sudo apt-get install jq -y"
 }
SETTINGS

  timeouts {
    create = "3m"
    delete = "3m"
  }
}

# Remote Execution for Nginx Status Retrieval
resource "null_resource" "get_nginx_status" {
  count     = 3
  depends_on = [azurerm_virtual_machine_extension.web_server_install]

  connection {
    host     = azurerm_public_ip.test.ip_address
    type     = "ssh"
    user     = "testadmin"
    password = "Password1234!"
    port     = 1022 + count.index * 1000
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    script = "./scripts/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /var/www/html"
    ]
  }
}

# Remote File Provisioning for Nginx Configuration
resource "null_resource" "get_nginx_status2" {
  count      = 3
  depends_on = [null_resource.get_nginx_status]

  connection {
    host     = azurerm_public_ip.test.ip_address
    type     = "ssh"
    user     = "testadmin"
    password = "Password1234!"
    port     = 1022 + count.index * 1000
    timeout  = "10s"
  }

  provisioner "file" {
    source      = "./html"
    destination = "/var/www"
  }
}

# Data Block for Remote File Retrieval (Nginx Status)
data "remotefile" "nginx_status" {
  count      = 3
  depends_on = [null_resource.get_nginx_status]

  conn {
    host     = azurerm_public_ip.test.ip_address
    port     = 1022 + count.index * 1000
    username = "testadmin"
    password = "Password1234!"
  }

  path = "/tmp/nginx.json"
}
