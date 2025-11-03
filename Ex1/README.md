# Exercise 1 - Single VNet with Virtual Machine

## Architecture

Overview:

<p align="center">
    <img src="./img/architecture.png" alt="Architecture diagram" width="400"/>
</p>


## Goal 

Deploy an Ubuntu 24.04 LTS virtual machine (VM) in Azure using Terraform. The VM should have 2 CPUs and 4 GB of RAM, and be placed in the default subnet (10.0.0.0/25) of the main virtual network (VNet 10.0.0.0/24).  
You will need to create the following files: `main.tf`, `variables.tf`, and `providers.tf`.
## Quickstart

Make sure the Azure CLI and Terraform are installed in your dev container (they are already available in this environment).

1. **Login to Azure**  
    ```bash
    az login
    ```

2. **Set your variables**  
    Create a `dev.tfvars` file in the `Ex1/` folder with the required variables (see example below).

    ```hcl
    subscription_id       = "xxxxxx"
    resource_group_name   = "rg-ex01"
    location              = "francecentral"
    virtual_network_name  = "vnet-1"
    subnet_name           = "subnet-1"
    vm_name               = "VM-1"
    vm_size               = "Standard_B1ms" # 1 vCPU, 2 GB RAM
    vm_username           = "MyAdminUser"
    vm_password           = "MyP@ssw0rd!"
    ```

3. **Deploy with Terraform**  
    Run the following commands from the project directory:
    ```bash
    # Initialize Terraform
    terraform init

    # Validate the configuration files
    terraform validate

    # Prepare the deployment plan
    terraform plan -var-file="dev.tfvars"

    # Apply the configuration to create resources
    terraform apply -var-file="dev.tfvars"
    ```

## Cleanup

To remove all resources created by this exercise, run:

```bash
terraform destroy -var-file="dev.tfvars"
```bash
terraform destroy -var-file="dev.tfvars"
```

