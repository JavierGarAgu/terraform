# Terraform configuration for a Google Compute Engine instance with an internal IP address

This Terraform configuration creates a Google Compute Engine instance with an internal IP address.

## Resources created

* A Google Compute Network named `my-network`
* A Google Compute Subnetwork named `my-subnet` within `my-network`
* A firewall rule to allow HTTP, SSH, RDP, and ICMP traffic
* A Google Compute Internal Address within `my-subnet`
* A Google Compute Instance named `vm-instance` with an internal IP address

## Files

* `main.tf`: Contains the Terraform configuration for the resources
* `providers.tf`: Contains the provider configuration for the Google Compute Engine provider

## Usage

To create this infrastructure, run the following command:

* `terraform apply`

This will create a new Google Compute Engine instance with the specified name and configuration. The instance will have an internal IP address in the 10.0.0.0/16 subnet.
Resources

Explanation

* The main.tf file contains the Terraform configuration for the resources. The providers.tf file contains the provider configuration for the Google Compute Engine provider.

* The resource "google_compute_network" "default" { block creates a Google Compute Network named my-network.

* The resource "google_compute_subnetwork" "default" { block creates a Google Compute Subnetwork named my-subnet within my-network.

* The resource "google_compute_firewall" "mynetwork-allow-http-ssh-rdp-icmp" { block creates a firewall rule to allow HTTP, SSH, RDP, and ICMP traffic.

* The resource "google_compute_address" "internal_with_subnet_and_address" { block creates a Google Compute Internal Address within my-subnet.

* The resource "google_compute_instance" "instance_with_ip" { block creates a Google Compute Instance named vm-instance with an internal IP address.

To learn more about this Terraform configuration, please see the following resources:

    Terraform documentation: https://www.terraform.io/docs/
    Google Compute Engine documentation: https://cloud.google.com/compute/docs/



