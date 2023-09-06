# Terraform Project: User, Group, and Web App Setup

This Terraform project automates the setup of users, groups, and a web app in Azure. It creates users and groups in Azure Active Directory and sets up a Linux web app with Azure AD authentication.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- Azure subscription and appropriate permissions

## Usage

1. Clone this repository to your local machine.

2. Update the `main.tf` and `providers.tf` files with your specific configurations and values.

3. Place a CSV file named `users.csv` in the same directory as the `.tf` files. This CSV should contain user details such as `first_name`, `last_name`, and `department`.

4. Open a terminal and navigate to the project directory.

5. Initialize the Terraform project:

`terraform init`

6.  Review the changes that will be applied:

`terraform plan` 

7.  Apply the changes:

`terraform apply` 

This will create users, groups, and the web app according to your configurations.

8.  To destroy the resources:

`terraform destroy -auto-approve` 

## Project Structure

-   `main.tf`: Defines the main resources including users, groups, and the web app.
-   `providers.tf`: Configures the required providers.
-   `users.csv`: CSV file containing user details.

## Configuration

-   Modify the values in `main.tf` and `providers.tf` to match your specific requirements.
-   Update the CSV file `users.csv` with user details.

## Note

-   Make sure to handle sensitive information securely, especially when dealing with authentication secrets.

## Acknowledgments

This project is created using Terraform and leverages Azure services.

## More info

This version should have consistent formatting throughout. Remember to replace placeholders like `your_tenant` and provide accurate descriptions for each section. Also, ensure that you provide the appropriate attribution, license information, and acknowledgments as needed for your specific project.

