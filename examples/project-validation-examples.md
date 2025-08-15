# Simple Project DNS Validation Examples

## Configuration
```hcl
approved_projects    = ["monika", "jarvis", "hal"]
approved_environments = ["lab", "dev", "staging", "prod"]
```

## Validation Logic
If `current_project` is set, only allow DNS records matching: `*-{current_project}-{env}`

## Examples for Project "monika"

### ✅ ALLOWED Records
```hcl
current_project = "monika"

# These would PASS validation:
"api-monika-lab"        # ✅ Matches pattern
"dashboard-monika-prod" # ✅ Matches pattern  
"web-monika-staging"    # ✅ Matches pattern
"service-monika-dev"    # ✅ Matches pattern
```

### ❌ BLOCKED Records
```hcl
current_project = "monika"

# These would FAIL validation:
"api-jarvis-lab"        # ❌ Wrong project (jarvis not monika)
"api-monika-test"       # ❌ Invalid environment (test not in list)
"monika.lab"            # ❌ Wrong pattern (needs hyphen format)
"www"                   # ❌ Doesn't match pattern
"mail-monika-lab"       # ❌ Would pass pattern but good to restrict
```

## Examples for Project "jarvis"

### ✅ ALLOWED Records
```hcl
current_project = "jarvis"

"api-jarvis-lab"        # ✅ Correct project and env
"nlp-jarvis-prod"       # ✅ Correct project and env
"ai-jarvis-staging"     # ✅ Correct project and env
```

### ❌ BLOCKED Records  
```hcl
current_project = "jarvis"

"api-monika-lab"        # ❌ Cannot modify monika's records
"api-hal-prod"          # ❌ Cannot modify hal's records
```

## Examples for Unauthorized Project

```hcl
current_project = "skynet"  # Not in approved_projects

# ALL records would fail with:
# "Project 'skynet' is not in the approved projects list: monika, jarvis, hal"
```

## DNSaC Admin Access

```hcl
current_project = ""  # Empty = admin access

# Can create ANY record (no validation):
"www"                   # ✅ Admin can modify
"mail"                  # ✅ Admin can modify
"api-monika-lab"        # ✅ Admin can modify
"@"                     # ✅ Admin can modify
```

## Usage in Practice

### 1. Project API Token Sets Variable
```hcl
# When monika project uses its API token
resource "cloudflare_record" "monika_api" {
  zone_id = var.zone_id
  name    = "api-monika-lab"  # ✅ Will pass
  type    = "A"
  value   = "10.0.1.5"
  
  # Token automatically sets:
  # current_project = "monika"
  # validate_dns_conflicts = true
}
```

### 2. Terraform Validates on Apply
```bash
# If monika tries to create "api-jarvis-lab":
terraform apply

Error: Project 'monika' cannot modify these records: api-jarvis-lab. 
Only records matching *-monika-{lab,dev,staging,prod} are allowed.
```

### 3. Zero-Downtime Deploy Pattern
```hcl
# Monika project can manage these:
"api-monika-lab"         → 10.0.1.5 (blue)
"api-v2-monika-lab"      → 10.0.1.6 (green)
"api-monika-prod"        → CNAME to api-monika-lab (production)

# Switch traffic:
"api-monika-prod"        → CNAME to api-v2-monika-lab (instant switch)
```

## Implementation in DNSaC

### Setting Project Context
```hcl
# When applying changes as a project:
terraform apply \
  -var="current_project=monika" \
  -var="validate_dns_conflicts=true"

# When applying as admin:
terraform apply  # current_project defaults to ""
```

### Project Token Creation
```hcl
# Create token that automatically sets project context
resource "cloudflare_api_token" "monika" {
  name = "monika-dns-token"
  
  # Token metadata would identify it as "monika" project
  # Application using token would pass current_project=monika
}
```