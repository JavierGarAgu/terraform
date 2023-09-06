output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.virtual_machine.public_ip_address
}

output "admin_password" {
  sensitive = true
  value     = azurerm_linux_virtual_machine.virtual_machine.admin_password
}

output "nginx_status_output" {
  value       = jsondecode(data.remotefile.nginx_status.content).sub
  description = "Estado de Nginx en la máquina virtual Debian."

  # Agrega una dependencia explícita al bloque data.external.nginx_status
  depends_on = [data.remotefile.nginx_status]
}

