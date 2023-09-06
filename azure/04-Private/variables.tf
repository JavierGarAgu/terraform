# General.

variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "prefix" {
  type        = string
  default     = "jga"
  description = "Prefix for all the resources"
}

# MySQL.

variable "mysqluser" {
  type        = string
  default     = "user04"
}

variable "mysqlpassword" {
  type        = string
  default     = "Strong!1234"
}

# VM.

variable "vmuser" {
  type        = string
  default     = "temporaladmin"
}

variable "vmpassword" {
  type        = string
  default     = "!1234Password"
}

