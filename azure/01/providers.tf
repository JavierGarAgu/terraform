terraform {
  required_version = ">=1.0"  # Specifies the minimum version of Terraform required.

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # Azure provider source and version constraints.
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"  # Random provider source and version constraints.
      version = "~>3.0"
    }
    remotefile = {
      source  = "mabunixda/remotefile"  # Custom "remotefile" provider source and version constraints.
      version = "~>0.1.1"
    }
  }
}

provider "azurerm" {
  features {}  # Configures the Azure provider with an empty features block.
}
