# variables.tf

# Variable to define the location of the Azure resource group.
variable "resource_group_location" {
  default     = "eastus"
  description = "Location of the resource group."
}

# Variable to specify the name of the script file used for provisioning.
variable "install" {
    type        = string
    default     = "scripts/install.sh"
}

# Variable to specify the name of the script file used for prepare the output.
variable "output" {
    type        = string
    default     = "scripts/output.sh"
}

# Variable to provide a prefix for naming resources.
variable "prefix" {
  type        = string
  description = "Prefix for naming resources."
  default     = "jga"
}

# Variable to define the name of the resource group.
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
  default     = "01-VM-Nginx-Webpage"
}

# Variable to specify the username for the virtual machine.
variable "user" {
  type        = string
  description = "Username of the virtual machine."
  default     = "adminazure"
}

# Variable to specify the password for the virtual machine.
variable "password" {
  type        = string
  description = "Password of the virtual machine."
  default     = "MyPassword#1234"
}
