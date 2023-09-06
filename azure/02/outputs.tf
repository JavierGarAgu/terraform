output "resource_group_name" {
  value = azurerm_resource_group.test.name
}

output "public_ip_address" {
  value = "${azurerm_public_ip.test.*.ip_address}"
}

output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value = zipmap(azurerm_linux_virtual_machine.test.*.name, azurerm_network_interface.test.*.private_ip_address)
}
