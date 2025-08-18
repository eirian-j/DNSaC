# Using DNSaC Module from External Terraform Projects

## How External Projects Can Use DNSaC Directly

Yes! External Terraform projects can call the DNSaC domain module directly. This is actually a very clean approach that maintains centralized control while allowing distributed management.

## Architecture Overview

```
[Project Monika Terraform] → [DNSaC Domain Module] → [CloudFlare API]
         ↓                            ↓
    Sets current_project      Validates against rules
         "monika"             Only allows *-monika-{env}
```

## Example: Project Monika's Terraform

### monika/terraform/dns.tf
```hcl
# Monika project using DNSaC module directly
module "monika_dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/domain?ref=main"
  
  # Required authentication
  cloudflare_account_id = var.cloudflare_account_id  # From monika's tfvars
  domain_name          = "eirian.io"
  
  # PROJECT IDENTIFICATION - Critical for validation
  current_project         = "monika"  # This enforces validation rules!
  validate_dns_conflicts  = true      # Enable project validation
  
  # Monika's DNS records - MUST follow *-monika-{env} pattern
  dns_records = {
    "api" = {
      name    = "api-monika-lab"      # ✅ Will pass validation
      content = var.monika_api_ip
      type    = "A"
      ttl     = 300
      proxied = true
    }
    "dashboard" = {
      name    = "dashboard-monika-prod"  # ✅ Will pass validation
      content = var.monika_dashboard_ip
      type    = "A"
      ttl     = 300
      proxied = true
    }
    # This would FAIL validation:
    # "hack" = {
    #   name    = "api-jarvis-lab"     # ❌ Cannot modify jarvis records!
    #   content = "10.0.0.1"
    #   type    = "A"
    # }
  }
  
  # Monika can also set TXT records for its services
  txt_records = {
    "verification" = {
      name    = "api-monika-lab"
      content = "monika-verification-${var.verification_code}"
      ttl     = 300
    }
  }
}
```

### monika/terraform/terraform.tfvars
```hcl
# Monika's variables
cloudflare_account_id = "your-account-id"
monika_api_ip        = "10.0.1.5"
monika_dashboard_ip  = "10.0.1.6"
verification_code    = "abc123"
```

### monika/terraform/providers.tf
```hcl
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.monika_cloudflare_token  # Scoped token with DNS edit permissions
}
```

## Example: Project Jarvis's Terraform

### jarvis/terraform/dns.tf
```hcl
module "jarvis_dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/domain?ref=main"
  
  cloudflare_account_id = var.cloudflare_account_id
  domain_name          = "eirian.io"
  
  # Jarvis identifies itself
  current_project         = "jarvis"
  validate_dns_conflicts  = true
  
  dns_records = {
    "nlp_service" = {
      name    = "nlp-jarvis-prod"     # ✅ Jarvis can create this
      content = module.jarvis_nlp.load_balancer_ip
      type    = "A"
      ttl     = 300
      proxied = true
    }
    "ai_api" = {
      name    = "ai-jarvis-lab"       # ✅ Jarvis can create this
      content = module.jarvis_ai.service_ip
      type    = "A"
      ttl     = 300
      proxied = true
    }
  }
}
```

## Security Benefits of This Approach

### 1. No Code Changes Needed in DNSaC
Projects use the existing module - no PRs or modifications to DNSaC repository required.

### 2. Validation Happens Automatically
```bash
# If Jarvis tries to create a Monika record:
terraform apply

Error: Project 'jarvis' cannot modify these records: api-monika-lab. 
Only records matching *-jarvis-{lab,dev,staging,prod} are allowed.
```

### 3. Each Project Manages Its Own State
```
monika/terraform/.terraform/terraform.tfstate  # Only monika's DNS records
jarvis/terraform/.terraform/terraform.tfstate  # Only jarvis's DNS records
hal/terraform/.terraform/terraform.tfstate     # Only hal's DNS records
```

### 4. CloudFlare Token Scoping
Each project gets a CloudFlare API token that can only:
- Read zone information
- Create/modify DNS records
- But validation logic in module prevents cross-project changes

## Complete Integration Example

### Project Structure
```
monika/
├── terraform/
│   ├── main.tf           # Monika's infrastructure
│   ├── dns.tf            # DNS configuration using DNSaC module
│   ├── variables.tf      
│   ├── terraform.tfvars  # Includes current_project = "monika"
│   └── providers.tf
└── kubernetes/
    └── deployments.yaml
```

### monika/terraform/main.tf
```hcl
# Monika's infrastructure
resource "kubernetes_deployment" "monika_api" {
  metadata {
    name = "monika-api"
  }
  # ... deployment config
}

resource "kubernetes_service" "monika_api" {
  metadata {
    name = "monika-api"
  }
  spec {
    type = "LoadBalancer"
    # ... service config
  }
}

# Get the LoadBalancer IP for DNS
data "kubernetes_service" "monika_api" {
  metadata {
    name = kubernetes_service.monika_api.metadata[0].name
  }
}
```

### monika/terraform/dns.tf
```hcl
# Automatically update DNS when service IP changes
module "monika_dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/domain?ref=main"
  
  cloudflare_account_id   = var.cloudflare_account_id
  domain_name            = "eirian.io"
  current_project        = "monika"
  validate_dns_conflicts = true
  
  dns_records = {
    "api" = {
      name    = "api-monika-${var.environment}"
      content = data.kubernetes_service.monika_api.status[0].load_balancer[0].ingress[0].ip
      type    = "A"
      ttl     = 300
      proxied = true
    }
  }
  
  depends_on = [kubernetes_service.monika_api]
}
```

## Deployment Workflow

### 1. Initial Setup (DNSaC Admin)
```bash
# In DNSaC repository - create API tokens for projects
cd DNSaC/
terraform apply -var="current_project=" # Admin mode

# Output tokens for distribution to projects
terraform output monika_api_token
terraform output jarvis_api_token
terraform output hal_api_token
```

### 2. Project Deployment (Monika Team)
```bash
# In Monika's repository
cd monika/terraform/

# Set CloudFlare token (from DNSaC admin)
export TF_VAR_monika_cloudflare_token="xxx"

# Deploy infrastructure AND DNS together
terraform plan  # Shows DNS records to be created
terraform apply # Creates infrastructure + DNS atomically
```

### 3. Updates Are Automatic
```bash
# When Monika updates their service
terraform apply

# Terraform automatically:
# 1. Deploys new service version
# 2. Gets new LoadBalancer IP
# 3. Updates DNS via DNSaC module
# 4. Validation ensures only monika records are modified
```

## Advantages Over API-Based Approach

| Aspect | Direct Module Usage | API-Based Approach |
|--------|-------------------|-------------------|
| **Setup Complexity** | Simple - just import module | Requires custom scripts |
| **Validation** | Built-in Terraform validation | Must implement separately |
| **State Management** | Terraform handles it | Manual state tracking |
| **Rollback** | `terraform destroy` works | Manual cleanup needed |
| **Audit Trail** | Terraform state history | Must build logging |
| **Infrastructure as Code** | Pure IaC approach | Mixed IaC + scripts |

## Migration Path for Existing Projects

### Step 1: Add DNS Module to Existing Terraform
```hcl
# Add to existing project's Terraform
module "project_dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/domain?ref=main"
  
  current_project = "monika"
  # ... DNS configuration
}
```

### Step 2: Import Existing DNS Records
```bash
# Import existing DNS records into Terraform state
terraform import module.project_dns.cloudflare_record.dns["api"] zone-id/record-id
```

### Step 3: Validate and Apply
```bash
terraform plan  # Verify no unexpected changes
terraform apply # Apply any necessary updates
```

## Best Practices

### 1. Pin Module Version
```hcl
module "monika_dns" {
  source = "git::https://github.com/eirian-j/DNSaC.git//modules/domain?ref=v1.0.0"
  # Use git tags instead of main for stability
}
```

### 2. Use Remote State
```hcl
terraform {
  backend "s3" {
    bucket = "monika-terraform-state"
    key    = "dns/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 3. Separate DNS Configuration
Keep DNS in a separate file (dns.tf) for clarity and potential separate deployment.

### 4. Use Data Sources for Dynamic IPs
```hcl
# Reference infrastructure outputs
data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "monika-terraform-state"
    key    = "infrastructure/terraform.tfstate"
  }
}

module "monika_dns" {
  # Use IP from infrastructure state
  dns_records = {
    "api" = {
      name    = "api-monika-lab"
      content = data.terraform_remote_state.infrastructure.outputs.api_ip
      type    = "A"
    }
  }
}
```

## Summary

Yes, external Terraform projects can absolutely use the DNSaC module directly by:
1. Importing the module from the Git repository
2. Setting `current_project` to their project name
3. Following the `*-{project}-{env}` naming convention
4. Using their scoped CloudFlare API token

This approach gives you:
- ✅ Centralized validation rules
- ✅ Distributed DNS management
- ✅ Automatic enforcement of naming conventions
- ✅ Infrastructure and DNS in sync
- ✅ Standard Terraform workflow
- ✅ No custom scripts or tools needed