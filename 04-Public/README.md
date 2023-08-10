# Azure MySQL Public Server and AKS Cluster Project

## Overview
Welcome to the Azure MySQL Public Server and Azure Kubernetes Service (AKS) Cluster Project. This project showcases the seamless integration of an Azure MySQL Server with an Azure Kubernetes Service (AKS) cluster. Notably, the MySQL connection configuration in this project is unrestricted, allowing for direct import of SQL content from your local machine.

## Project Scope
This initiative encompasses a holistic integration of resources, combining the robust capabilities of an Azure MySQL Server with the agility of an Azure Kubernetes Service (AKS) cluster. A key aspect of this integration is the non-restricted configuration of the MySQL connection. This unique attribute simplifies the process of importing SQL content, leveraging the computational power of your local machine.

## File Structure and Contents

- `providers.tf`: Essential configuration file for Terraform providers.
- `main.tf`: Orchestrates the general configuration for Azure and AKS.
- `mysql.tf`: Specific configuration for the Azure MySQL Database.
- `variables.tf`: Centralizes variables used throughout the project.
- `outputs.tf`: Provides crucial information for AKS connection and verification.
- `coches.sql`: Contains SQL content ready for import.
- `python`: Contains a custom AKS application available on Docker Hub [link](https://hub.docker.com/repository/docker/javiergaragu/04app/general).

## Deployment Steps

1. Install Terraform to initiate the deployment process.
2. Initialize the deployment with `terraform init`.
3. Generate a creation plan using `terraform plan -out plancreate`.
4. Execute the creation plan with `terraform apply plancreate`.

**Note**: The deployment process may take approximately 15 minutes.

Upon completion, access the provided public IP in the output. This will allow you to access the pod's hostname and MySQL content. Reloading the page will show a change in the hostname.

![webapp](https://github.com/JavierGarAgu/terraform/blob/master/04-Public/images/show.png)

## Azure Resources and Tear Down

Gain insights into the generated Azure resources:

![Resources](https://github.com/JavierGarAgu/terraform/blob/master/04-Public/images/show2.png)

When it's time to conclude, gracefully dismantle your infrastructure:

1. Prepare the teardown: `terraform plan -destroy -out plandestroy`.
2. Execute the teardown plan: `terraform apply plandestroy`.

## Testing and Further Exploration

Test Azure MySQL without the AKS cluster:

1. Python Testing: Use the provided Python code in this repository. Navigate to the `python` folder, create a virtual environment, and install the requirements from `requirements.txt`.

2. Docker Container: Explore this resource [link](https://hub.docker.com/repository/docker/javiergaragu/04app/general) for Docker container details.

## Potential Enhancements

Elevate the project with these future considerations:

- Implement MySQL Best Practices: Strengthen MySQL security using industry best practices.
- Azure Key Vault Integration: Enhance data security by utilizing Azure Key Vault for sensitive information.
- Automated Imports: Configure scheduled jobs to automate SQL content imports.
- Scalability Extension: Expand the AKS cluster for scalability demands.

Feel free to explore additional enhancements that align with evolving requirements.

Embark on this project journey, leveraging Azure services to seamlessly unite your local SQL resources with the boundless possibilities of the cloud. This effort not only showcases your technical prowess but also demonstrates your ability to fluidly harness sophisticated technologies for impactful outcomes.
