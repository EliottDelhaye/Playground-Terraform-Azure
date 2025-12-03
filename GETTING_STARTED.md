# Getting Started with Terraform

## 🎯 What is Terraform?

Terraform est un outil d'Infrastructure as Code (IaC) qui permet de définir, provisionner et gérer votre infrastructure cloud via des fichiers de configuration déclaratifs.

## 📁 Structure d'un projet Terraform

```
Ex1/
├── main.tf           # Ressources principales (VMs, VNets, etc.)
├── variables.tf      # Déclaration des variables
├── providers.tf      # Configuration du provider Azure
├── outputs.tf        # Valeurs à afficher après déploiement
└── dev.tfvars        # Valeurs des variables (ne JAMAIS commit!)
```

## 🔄 Le Workflow Terraform

### 1. **init** - Initialiser le projet
```bash
terraform init
```
- Télécharge les providers (azurerm, random, etc.)
- Initialise le backend pour stocker l'état
- À faire **une seule fois** par projet (ou après ajout de providers)

### 2. **plan** - Prévisualiser les changements
```bash
terraform plan -var-file="dev.tfvars"
```
- Montre ce qui sera créé/modifié/détruit
- ✅ **+ create** = nouvelle ressource
- **~ update** = modification
- ❌ **- destroy** = suppression
- **Aucune action réelle** - juste une prévisualisation

### 3. **apply** - Déployer l'infrastructure
```bash
terraform apply -var-file="dev.tfvars"
```
- Crée/modifie réellement les ressources Azure
- Demande confirmation (taper `yes`)
- Durée: 3-7 minutes selon l'exercice
- Créé un fichier `terraform.tfstate` (l'état actuel)

### 4. **output** - Afficher les résultats
```bash
terraform output
```
- Affiche les valeurs définies dans `outputs.tf`
- Ex: IPs, URLs, noms de ressources

### 5. **destroy** - Supprimer l'infrastructure
```bash
terraform destroy -var-file="dev.tfvars"
```
- ⚠️ **ATTENTION**: Supprime TOUTES les ressources
- 💰 **Important**: Toujours destroy après les exercices pour éviter les coûts!

## 🔑 Concepts clés

### Variables
Permettent de paramétrer votre code:
```hcl
variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  default     = "my-vm"
}
```

### Ressources
Les éléments d'infrastructure à créer:
```hcl
resource "azurerm_virtual_network" "vnet" {
  name     = "my-vnet"
  location = "francecentral"
  # ...
}
```

### Data Sources
Récupérer des infos existantes sans les créer:
```hcl
data "azurerm_resource_group" "existing" {
  name = "my-rg"
}
```

### Outputs
Afficher des informations après déploiement:
```hcl
output "vm_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}
```

## 🛡️ Bonnes pratiques

1. **Ne JAMAIS commiter** les fichiers `.tfvars` ou `.tfstate`
2. **Toujours faire `plan`** avant `apply`
3. **Utiliser des noms descriptifs** pour les ressources
4. **Documenter vos variables** avec `description`
5. **Taguer vos ressources** pour faciliter la gestion
6. **Détruire les ressources** après les tests pour économiser

## 🚨 Erreurs courantes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `terraform: command not found` | Terraform non installé | Utiliser le dev container |
| `Error: Unauthorized` | Pas authentifié Azure | `az login` |
| `Error: Subscription not found` | Mauvais subscription_id | Vérifier avec `az account list` |
| `Error: Resource already exists` | Ressource déjà créée | Changer le nom ou faire `destroy` d'abord |
| `Error acquiring state lock` | Terraform déjà en cours | Attendre ou supprimer le lock |

## 📚 Commandes utiles

```bash
# Afficher la version
terraform version

# Valider la syntaxe
terraform validate

# Formater le code
terraform fmt

# Afficher l'état actuel
terraform show

# Lister les ressources
terraform state list

# Obtenir votre subscription ID
az account show --query id -o tsv

# Voir vos resource groups
az group list --output table
```

## 🔗 Ressources

- [Terraform Documentation](https://www.terraform.io/docs/)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

Prêt ? Commencez par [Exercise 1](Ex1/) ! 🚀
