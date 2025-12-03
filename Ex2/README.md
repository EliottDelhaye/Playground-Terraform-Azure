# Exercise 2 - Load Balancer with Virtual Machines

## Learn

### Load Balancer Overview
An Azure Load Balancer is a Layer 4 (Transport Layer) load balancer that distributes incoming network traffic across multiple backend resources, such as virtual machines (VMs), to ensure high availability and reliability of applications. It operates at the TCP and UDP protocols and can handle millions of requests per second with low latency.

### Hash-Tuple Based Distribution
Azure Load Balancer uses a hash-based distribution algorithm to distribute incoming network traffic across multiple backend resources. The hash is computed based on a combination of fields from the incoming packet, typically including:

- Source IP address
- Source port
- Destination IP address
- Destination port
- Protocol type

This combination of fields is referred to as a "5-tuple" (or "2-tuple" in some cases).

## Exercise Specifications

**Architecture Overview:**

<p align="center">
    <img src="./img/architecture.png" alt="Architecture diagram" width="400"/>
</p>

Deploy two virtual machines in Azure using Terraform, and place them behind an Azure Load Balancer.

> 💡 **Need help?** The complete solution is available in [`solution/`](./solution/)

- **Virtual Network**
    - **Name:** `vnet-1`
    - **Address Space:** `10.0.0.0/16`
- **Subnet**
    - **Name:** `subnet-1`
    - **Address Prefix:** `10.0.0.0/24`
- **Virtual Machines**
    - **VM-1**
        - **Size:** `Standard_B1ms` (1 vCPU, 2 GB RAM)
        - **Private IP:** `10.0.0.4`
    - **VM-2**
        - **Size:** `Standard_B1ms` (1 vCPU, 2 GB RAM)
        - **Private IP:** `10.0.0.5`
- **Load Balancer**
    - **Name:** `lb-1`
    - **Frontend IP:** Public IP assigned by Azure
    - **Backend Pool:** Includes `VM-1` and `VM-2`
    - **Health Probe:** TCP probe on port `80`
    - **Load Balancing Rule:** Distributes HTTP traffic (port `80`) to backend VMs

Each VM automatically installs Nginx via cloud-init and displays its private IP address on a simple HTML page.

## Quickstart

The Azure CLI and Terraform are pre-installed in this dev container.

### 1. Login to Azure
```bash
az login
```

### 2. Set Your Variables
Create a `dev.tfvars` file in the `Ex2/` folder with the required variables:

```hcl
subscription_id       = "your-subscription-id"
resource_group_name   = "rg-ex02"
location              = "francecentral"
virtual_network_name  = "vnet-1"
subnet_name           = "subnet-1"
load_balancer_name    = "lb-1"
vm_size               = "Standard_B1ms"
vm_username           = "azureuser"
vm_password           = "YourSecurePassword123!"
```

> **Security Note**: Never commit the `dev.tfvars` file to version control. It's already listed in `.gitignore`.

### 3. Initialize Terraform
```bash
cd Ex2/
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

Deployment takes approximately 5-7 minutes.

### 6. Test the Load Balancer

After deployment, retrieve the outputs:

```bash
terraform output
```

**Test from your local machine:**

```bash
# Get the Load Balancer public IP
LB_IP=$(terraform output -raw load_balancer_public_ip)

# Test the Load Balancer
curl http://$LB_IP

# Test load distribution (run multiple times)
for i in {1..10}; do curl -s http://$LB_IP | grep "Private IP"; done
```

**Expected output:**
```html
<h2>Private IP: 10.0.0.4</h2>
<h2>Private IP: 10.0.0.5</h2>
<h2>Private IP: 10.0.0.4</h2>
<h2>Private IP: 10.0.0.5</h2>
...
```

You should see responses alternating between both VMs, demonstrating the Load Balancer's hash-based distribution algorithm.

**Or open in your browser:**
```bash
echo "http://$LB_IP"
```

### 7. Clean Up Resources
```bash
terraform destroy -var-file="dev.tfvars"
```

## Architecture Components

| Resource Type | Name | Purpose |
|--------------|------|------|
| Resource Group | `rg-ex02` | Container for all resources |
| Virtual Network | `vnet-1` | Private network (10.0.0.0/16) |
| Subnet | `subnet-1` | VM subnet (10.0.0.0/24) |
| Public IP | `pip-lb-1` | Load Balancer public IP |
| Load Balancer | `lb-1` | Traffic distribution |
| Backend Pool | `lb-be` | Contains both VMs |
| Health Probe | `probe-80` | TCP health check on port 80 |
| NSG | `nsg-web` | Network security rules |
| Virtual Machines | `VM-1`, `VM-2` | Ubuntu with Nginx (Standard_B1ms) |

## Key Learning Points

1. **Load Balancer**: Distributes traffic across multiple VMs for high availability
2. **Backend Pools**: Group of VMs receiving traffic from the Load Balancer
3. **Health Probes**: Monitor VM availability and remove unhealthy instances
4. **Load Balancing Rules**: Define how traffic is distributed (protocol, ports)
5. **Network Security Groups**: Control inbound/outbound traffic with security rules
6. **Cloud-init**: Automate VM configuration at deployment time
7. **Static IPs**: Assign specific private IPs to VMs for predictability

## Troubleshooting

### Cannot access the Load Balancer from internet
- Verify NSG allows inbound traffic on port 80
- Check the public IP is allocated: `az network public-ip show`
- Ensure both VMs are in the backend pool

### Load Balancer returns no response
- Check health probe status in Azure Portal
- Verify Nginx is running on both VMs (use Serial Console)
- Wait 2-3 minutes for Nginx installation to complete

### Only one VM responds
- Check backend pool association for both NICs
- Verify both VMs pass the health probe
- Review NSG rules for both VMs

### Hash-based distribution not working
- This is expected behavior! The Load Balancer uses a 5-tuple hash
- From the same source IP, you may consistently hit the same VM
- Try from different source IPs or wait for connection timeout

## Next Steps

Try **Exercise 3** to learn about:
- Hub-Spoke network architecture
- VNet Peering for multi-VNet connectivity
- Internal Load Balancers (private traffic)
- NAT Gateway for secure outbound connectivity
- Application Security Groups
