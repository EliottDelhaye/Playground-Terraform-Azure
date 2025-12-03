# Azure Terraform Playground

[![Terraform](https://img.shields.io/badge/Terraform-≥1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?logo=microsoft-azure)](https://azure.microsoft.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive collection of hands-on Terraform exercises for learning Azure networking, load balancing, and infrastructure deployment. Perfect for beginners and intermediate users looking to master Infrastructure as Code (IaC) with Azure.

## 📚 Overview

This repository contains 4 progressive exercises that teach Azure networking concepts through practical implementation:

1. **Basic Virtual Network & VM** - Foundation concepts
2. **Public Load Balancer** - High availability and traffic distribution
3. **Hub-Spoke Architecture** - Enterprise network patterns with internal load balancing
4. **Dual Load Balancers** - Complex scenarios with both internal and external load balancing

Each exercise builds upon the previous one, gradually introducing more advanced concepts and real-world architectures.

## 🎯 Learning Objectives

By completing these exercises, you will learn:

- ✅ Azure Virtual Networks (VNets) and Subnets
- ✅ Virtual Machines deployment and configuration
- ✅ Load Balancers (Internal and External)
- ✅ Hub-Spoke network topology
- ✅ VNet Peering
- ✅ Network Security Groups (NSG)
- ✅ Application Security Groups (ASG)
- ✅ NAT Gateway for outbound connectivity
- ✅ Infrastructure as Code best practices with Terraform

## 📋 Prerequisites

- **Azure Subscription** - [Get a free account](https://azure.microsoft.com/free/)
- **Azure CLI** - Pre-installed in the dev container
- **Terraform** - Pre-installed in the dev container
- **Basic knowledge** of networking concepts
- **VS Code** with Dev Containers extension (recommended)

## 🚀 Getting Started

### Option 1: Using Dev Container (Recommended)

This repository includes a complete dev container configuration with all tools pre-installed.

1. Clone the repository:
   ```bash
   git clone https://github.com/EliottDelhaye/Playground-Terraform-Azure.git
   cd Playground-Terraform-Azure
   ```

2. Open in VS Code:
   ```bash
   code .
   ```

3. When prompted, click "Reopen in Container" (or use Command Palette: `Dev Containers: Reopen in Container`)

4. Login to Azure:
   ```bash
   az login
   ```

### Option 2: Local Installation

Install the required tools:
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Terraform](https://www.terraform.io/downloads.html) (≥ 1.0)

## 📖 Exercises

### Exercise 1: Single VNet with Virtual Machine

**Difficulty:** 🟢 Beginner  
**Duration:** ~15 minutes

Learn the fundamentals by deploying a single Ubuntu VM in an Azure Virtual Network.

**Topics Covered:**
- Virtual Networks and Subnets
- Virtual Machine creation
- Network Interfaces
- Basic Terraform workflow

[📘 Go to Exercise 1](Ex1/)

---

### Exercise 2: Load Balancer with Virtual Machines

**Difficulty:** 🟡 Intermediate  
**Duration:** ~25 minutes

Deploy two VMs behind an Azure Load Balancer with automated Nginx installation.

**Topics Covered:**
- Public Load Balancers
- Backend Pools
- Health Probes
- Load Balancing Rules
- Network Security Groups
- Cloud-init configuration

[📘 Go to Exercise 2](Ex2/)

---

### Exercise 3: Hub-Spoke Architecture with Internal Load Balancer

**Difficulty:** 🟠 Advanced  
**Duration:** ~35 minutes

Implement a Hub-Spoke network topology with internal load balancing and NAT Gateway.

**Topics Covered:**
- Hub-Spoke network topology
- VNet Peering
- Internal Load Balancer
- NAT Gateway
- Application Security Groups
- Multi-VNet architectures

[📘 Go to Exercise 3](Ex3/)

---

### Exercise 4: Dual Load Balancers (Internal + External)

**Difficulty:** 🔴 Expert  
**Duration:** ~40 minutes

Deploy a complete architecture with both internal and external load balancers.

**Topics Covered:**
- Multiple Load Balancers
- Internet-facing applications
- Multiple Backend Pools
- Complex NSG configurations
- Production-ready patterns

[📘 Go to Exercise 4](Ex4/)

## 📁 Repository Structure

```
.
├── Ex1/                    # Exercise 1: Basic VNet & VM
│   ├── README.md          # Exercise instructions & specifications
│   ├── img/               # Architecture diagrams
│   └── solution/          # Complete solution (main.tf, variables.tf, etc.)
│
├── Ex2/                    # Exercise 2: Load Balancer
│   ├── README.md          # Exercise instructions & specifications
│   ├── img/               # Architecture diagrams
│   └── solution/          # Complete solution
│
├── Ex3/                    # Exercise 3: Hub-Spoke Architecture
│   ├── README.md          # Exercise instructions & specifications
│   ├── img/               # Architecture diagrams
│   └── solution/          # Complete solution
│
├── Ex4/                    # Exercise 4: Dual Load Balancers
│   ├── README.md          # Exercise instructions & specifications
│   ├── img/               # Architecture diagrams
│   └── solution/          # Complete solution
│
├── .devcontainer/         # VS Code Dev Container configuration
└── README.md              # This file
```

### 🎯 How to Use This Repository

1. **Read the exercise README** in each `ExX/` folder to understand what to build
2. **Create your Terraform files** directly in the exercise folder (e.g., `Ex1/main.tf`)
3. **Deploy and test** your infrastructure
4. **Compare with the solution** in `ExX/solution/` if needed

> 💡 **Learning Tip**: Try to complete each exercise on your own first before looking at the solution!

## 💡 Usage Tips

### Variable Configuration

Each exercise requires a `terraform.tfvars` or `dev.tfvars` file. Example:

```hcl
subscription_id  = "your-subscription-id"
location         = "francecentral"
admin_username   = "azureuser"
admin_password   = "YourSecurePassword123!"
```

> ⚠️ **Security Note**: Never commit `.tfvars` files to version control. They're already listed in `.gitignore`.

### Common Commands

```bash
# Initialize Terraform (first time only)
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# Show outputs
terraform output

# Destroy infrastructure
terraform destroy
```

### Cost Management

These exercises use small VM sizes to minimize costs:
- Ex1: 1× Standard_B2s (~$30/month)
- Ex2: 2× Standard_B1ms (~$30/month)
- Ex3-4: 3× Standard_B1ms (~$45/month)

💰 **Remember to run `terraform destroy` after completing each exercise to avoid unnecessary charges.**

## 🛠️ Troubleshooting

### Common Issues

**Issue**: `terraform init` fails
- **Solution**: Ensure you have internet connectivity and Azure CLI is authenticated

**Issue**: `terraform apply` fails with authentication error
- **Solution**: Run `az login` and ensure you're logged into the correct subscription

**Issue**: NSG rules not working
- **Solution**: Check rule priorities (lower number = higher priority)

**Issue**: Cannot access VMs
- **Solution**: Use Azure Portal's Serial Console or deploy Azure Bastion

### Get Help

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Networking Documentation](https://docs.microsoft.com/azure/virtual-network/)
- [Open an Issue](https://github.com/EliottDelhaye/Playground-Terraform-Azure/issues)

## 🔒 Security Best Practices

1. **Never commit credentials** - Use `.tfvars` files (already in `.gitignore`)
2. **Use strong passwords** - Or better, use SSH keys with `azurerm_linux_virtual_machine`
3. **Implement Azure Key Vault** - For production environments
4. **Enable Azure Security Center** - Monitor security posture
5. **Use Managed Identities** - Avoid hardcoded credentials
6. **Regular updates** - Keep Terraform and providers up to date

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

## 📧 Contact

Eliott Delhaye - [@EliottDelhaye](https://github.com/EliottDelhaye)

Project Link: [https://github.com/EliottDelhaye/Playground-Terraform-Azure](https://github.com/EliottDelhaye/Playground-Terraform-Azure)

---

⭐ **If you find this repository helpful, please consider giving it a star!**

Happy Learning! 🚀
