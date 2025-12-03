# Exercise 1 - Single VNet with Virtual Machine

## Learn

### Virtual Network Overview
An Azure Virtual Network (VNet) is a representation of your own network in the cloud. It is a logical isolation of the Azure cloud dedicated to your subscription. VNets enable you to securely connect Azure resources to each other, to the internet, and to on-premises networks. Virtual Networks are fundamental building blocks for your private network in Azure.

### Subnet Architecture
Subnets enable you to segment the virtual network into one or more sub-networks and allocate a portion of the virtual network's address space to each subnet. You can then deploy Azure resources in a specific subnet. Just like in a traditional network, subnets allow you to segment your VNet address space into segments that are appropriate for the organization's internal network.

## Exercise Specifications

**Architecture Overview:**

<p align="center">
    <img src="./img/architecture.png" alt="Architecture diagram" width="400"/>
</p>

Deploy an Ubuntu 24.04 LTS virtual machine (VM) in Azure using Terraform. The VM should be placed in a virtual network with proper subnet configuration.

- **Virtual Network**
    - **Name:** `vnet-1`
    - **Address Space:** `10.0.0.0/24`
- **Subnet**
    - **Name:** `subnet-1`
    - **Address Prefix:** `10.0.0.0/25`
- **Virtual Machine**
    - **Name:** `VM-1`
    - **Size:** `Standard_B2s` (2 vCPUs, 4 GB RAM)
    - **Operating System:** Ubuntu 24.04 LTS
    - **Network:** Connected to `subnet-1`

## Quickstart

The Azure CLI and Terraform are pre-installed in this dev container.

### 1. Login to Azure
```bash
az login
```

### 2. Set Your Variables
Create a `dev.tfvars` file in the `Ex1/` folder with the required variables:

```hcl
subscription_id       = "your-subscription-id"
resource_group_name   = "rg-ex01"
location              = "francecentral"
virtual_network_name  = "vnet-1"
subnet_name           = "subnet-1"
vm_name               = "VM-1"
vm_size               = "Standard_B2s"
vm_username           = "azureuser"
vm_password           = "YourSecurePassword123!"
```

> **Security Note**: Never commit the `dev.tfvars` file to version control. It's already listed in `.gitignore`.

### 3. Initialize Terraform
```bash
cd Ex1/
terraform init
```

### 4. Preview the Changes
```bash
terraform plan -var-file="dev.tfvars"
```

### 5. Deploy the Infrastructure
```bash
terraform apply -var-file="dev.tfvars"
```

Deployment takes approximately 3-5 minutes.

### 6. View the Outputs

After deployment, view the created resources:

```bash
terraform output
```

You should see:
- Resource group name
- Virtual network name
- VM name and private IP address

### 7. Clean Up Resources
```bash
terraform destroy -var-file="dev.tfvars"
```

## Architecture Components

| Resource Type | Name | Purpose |
|--------------|------|------|
| Resource Group | `rg-ex01` | Container for all resources |
| Virtual Network | `vnet-1` | Private network (10.0.0.0/24) |
| Subnet | `subnet-1` | VM subnet (10.0.0.0/25) |
| Network Interface | `VM-1-nic` | VM network connectivity |
| Virtual Machine | `VM-1` | Ubuntu 24.04 LTS (Standard_B2s) |

## Key Learning Points

1. **Virtual Networks (VNet)**: Isolated network environment in Azure
2. **Subnets**: Network segmentation within a VNet
3. **Network Interfaces**: Connection between VM and VNet
4. **Resource Groups**: Logical container for Azure resources
5. **Terraform Basics**: Infrastructure as Code workflow

## Troubleshooting

### Terraform init fails
- Ensure you have internet connectivity
- Verify Azure CLI is authenticated: `az account show`

### Terraform apply fails
- Check your subscription has sufficient quota for Standard_B2s VMs
- Verify the location supports the VM size: `az vm list-skus --location francecentral`

### Cannot access the VM
- VMs in this exercise don't have public IPs by design
- Use Azure Portal's Serial Console for access if needed

## Next Steps

Try **Exercise 2** to learn about:
- Load Balancers for high availability
- Multiple VMs and traffic distribution
- Health probes and backend pools
- Public IP addresses and internet connectivity

