# DNSaC Future Enhancements & Roadmap

This document outlines planned improvements for the DNSaC (DNS as Code) platform, categorized by priority and implementation timeline.

## 🎯 Current Status

**Completed:**
- ✅ Multi-domain architecture with 6 domains
- ✅ Enterprise email security (SPF, DMARC p=reject, DKIM)
- ✅ CAA records for certificate authority authorization
- ✅ DNSSEC with modern ECDSA signatures
- ✅ External project subdomain validation
- ✅ SSL strict mode with HTTP/3 and performance optimizations

## 📅 Implementation Roadmap

### Phase 1: Security & Compliance (Immediate - Week 1)

#### A. Enhanced Email Security
```hcl
# BIMI Records for Brand Protection
"bimi" = {
  name    = "default._bimi"
  content = "v=BIMI1; l=https://eirian.io/logo.svg; a=https://eirian.io/bimi-cert.pem"
  type    = "TXT"
}

# Enhanced DMARC Monitoring
"dmarc_forensic_mailbox" = {
  name    = "_dmarc-forensic"
  content = "v=DMARC1; ruf=mailto:dmarc-forensic@eirian.io"
  type    = "TXT"
}
```

#### B. DNS Security Headers
```hcl
# Additional DNS Security Records
variable "security_txt_record" {
  description = "Security.txt for vulnerability disclosure"
  default = {
    name    = "_security"
    content = "v=spf1 include:spf.eirian.io -all"
    type    = "TXT"
  }
}
```

#### C. Pre-commit Security Validation
```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: terraform-validate
        name: Terraform Validate
        entry: terraform validate
        language: system
        pass_filenames: false
      - id: dns-security-check
        name: DNS Security Validation
        entry: ./scripts/validate-dns-security.sh
        language: script
      - id: dmarc-policy-check
        name: DMARC Policy Validation
        entry: ./scripts/check-dmarc-compliance.sh
        language: script
```

### Phase 2: Infrastructure & Management (Short Term - Month 1)

#### A. Environment Separation
```hcl
# Environment-specific configurations
# File structure:
# terraform/environments/production/
# terraform/environments/staging/ 
# terraform/environments/development/

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be production, staging, or development."
  }
}

# Environment-specific domain configurations
locals {
  domain_configs = {
    production = {
      ttl = 300
      proxy_enabled = true
      security_level = "high"
    }
    staging = {
      ttl = 60
      proxy_enabled = false
      security_level = "medium"
    }
    development = {
      ttl = 60
      proxy_enabled = false
      security_level = "low"
    }
  }
}
```

#### B. Enhanced Monitoring & Alerting
```hcl
# Advanced CloudFlare Notification Policies
resource "cloudflare_notification_policy" "dns_record_changes" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC DNS Record Changes"
  description = "Alert on unauthorized DNS modifications"
  enabled     = true
  alert_type  = "zone_aop_custom"
  
  email_integration {
    id = var.notification_email
  }
  
  webhooks_integration {
    id = var.slack_webhook_id
  }
}

resource "cloudflare_notification_policy" "security_events" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Security Events"
  description = "Security incidents and anomalies"
  enabled     = true
  alert_type  = "dos_attack_l7"
  
  email_integration {
    id = var.security_email
  }
  
  pagerduty_integration {
    id = var.pagerduty_service_key
  }
}
```

#### C. Domain Registry Management
```hcl
# Domain metadata tracking
variable "domain_registry_info" {
  description = "Domain registrar and expiration tracking"
  type = map(object({
    registrar             = string
    expiration_date       = string
    auto_renew           = bool
    nameservers_delegated = bool
    owner_contact        = string
    renewal_notification_days = number
  }))
  default = {
    "eirian.io" = {
      registrar = "Namecheap"
      expiration_date = "2025-12-01"
      auto_renew = true
      nameservers_delegated = true
      owner_contact = "admin@eirian.io"
      renewal_notification_days = 30
    }
    # Additional domains...
  }
}

# Domain expiration monitoring
locals {
  domains_expiring_soon = [
    for domain, info in var.domain_registry_info :
    domain if timeadd(timestamp(), "${info.renewal_notification_days * 24}h") > info.expiration_date
  ]
}
```

### Phase 3: External Project Integration (Medium Term - Quarter 1)

#### A. Project Access Control Framework
```hcl
# Enhanced project token management
resource "cloudflare_api_token" "project_token" {
  count = length(var.external_projects)
  name  = "DNSaC-${var.external_projects[count.index].name}"
  
  policy {
    effect = "allow"
    permission_groups = [
      "c8fed203ed3043cba015a93ad1616f1f", # Zone:Read
      "4755a26eedb94da69e1066d98aa820be", # DNS:Edit
    ]
    resources = {
      "com.cloudflare.api.account.zone.${var.external_projects[count.index].zone_id}" = "*"
    }
  }
  
  condition {
    request_ip {
      in = var.external_projects[count.index].allowed_ips
    }
  }
  
  # Token expires annually for security
  expires_on = timeadd(timestamp(), "8760h")
}

# Project subdomain validation
variable "external_projects" {
  description = "External project configurations"
  type = list(object({
    name                = string
    zone_id            = string
    allowed_ips        = list(string)
    allowed_subdomains = list(string)
    contact_email      = string
    token_expires      = string
  }))
  default = []
}
```

#### B. Automated Project Onboarding
```hcl
# Project onboarding automation
module "project_onboarding" {
  source = "./modules/project-onboarding"
  
  for_each = { for project in var.external_projects : project.name => project }
  
  project_name       = each.value.name
  project_contact    = each.value.contact_email
  zone_id           = each.value.zone_id
  allowed_subdomains = each.value.allowed_subdomains
  
  # Generate secure API token
  generate_token    = true
  token_permissions = ["dns:edit", "zone:read"]
  
  # Create project documentation
  generate_docs     = true
  docs_template     = "project-integration-guide"
}
```

### Phase 4: Advanced Features (Long Term - Ongoing)

#### A. State Management Security
```hcl
# Enhanced Terraform backend configuration
terraform {
  backend "s3" {
    bucket         = "dnsac-terraform-state-${var.environment}"
    key            = "dns/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
    versioning     = true
    
    # State locking with DynamoDB
    dynamodb_table = "terraform-state-locks"
    
    # MFA requirement for state modifications
    role_arn       = var.terraform_state_role_arn
    external_id    = var.terraform_external_id
    
    # Server-side encryption
    kms_key_id     = var.state_encryption_key
  }
  
  # Required providers with version constraints
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### B. Automated Testing & CI/CD
```yaml
# .github/workflows/dns-validation.yml
name: DNS Security Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [production, staging, development]
    
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.6.0
          
      - name: Terraform Init
        run: terraform init
        env:
          TF_VAR_environment: ${{ matrix.environment }}
          
      - name: Terraform Validate
        run: terraform validate
        
      - name: Terraform Plan
        run: terraform plan -var-file="environments/${{ matrix.environment }}/terraform.tfvars"
        
      - name: DNS Security Check
        run: ./scripts/validate-dns-records.sh ${{ matrix.environment }}
        
      - name: DMARC Policy Validation
        run: ./scripts/check-dmarc-compliance.sh
        
      - name: CAA Record Validation
        run: ./scripts/validate-caa-records.sh
        
      - name: External Project Conflict Check
        run: ./scripts/check-project-conflicts.sh
        
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: '.'
          
  deploy:
    needs: [validate, security-scan]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: terraform apply -auto-approve
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
```

#### C. Advanced DNS Analytics
```hcl
# DNS query analytics and monitoring
resource "cloudflare_logpush_job" "dns_logs" {
  enabled          = true
  name             = "dns-query-logs"
  logpull_options  = "fields=ClientIP,ClientRequestHost,ClientRequestMethod,EdgeResponseStatus,RayID"
  destination_conf = "s3://dnsac-logs/dns-queries/{DATE}?region=us-east-1"
  
  filter = jsonencode({
    where = {
      and = [
        { eq = { ClientRequestHost = var.domain_name } },
        { neq = { EdgeResponseStatus = 200 } }
      ]
    }
  })
}

# CloudWatch dashboard for DNS metrics
resource "aws_cloudwatch_dashboard" "dns_dashboard" {
  dashboard_name = "DNSaC-Dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Route53", "QueryCount", "HostedZoneId", local.zone_id],
            ["AWS/CloudFront", "Requests", "DistributionId", local.distribution_id]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "DNS Query Volume"
        }
      }
    ]
  })
}
```

## 🛠️ Supporting Scripts & Tools

### DNS Security Validation Scripts

#### validate-dns-security.sh
```bash
#!/bin/bash
# DNS security validation script

set -euo pipefail

DOMAIN=${1:-"eirian.io"}
NAMESERVER="rob.ns.cloudflare.com"

echo "🔍 Validating DNS security for ${DOMAIN}..."

# Check CAA records
echo "Checking CAA records..."
if dig @${NAMESERVER} CAA ${DOMAIN} | grep -q "issue"; then
    echo "✅ CAA records found"
else
    echo "❌ Missing CAA records"
    exit 1
fi

# Validate DMARC policy
echo "Checking DMARC policy..."
DMARC_RECORD=$(dig @${NAMESERVER} TXT _dmarc.${DOMAIN} +short | tr -d '"')
if echo "${DMARC_RECORD}" | grep -q "p=reject"; then
    echo "✅ DMARC policy is strict (p=reject)"
else
    echo "❌ DMARC policy should be p=reject"
    exit 1
fi

# Check SPF record
echo "Checking SPF record..."
SPF_RECORD=$(dig @${NAMESERVER} TXT ${DOMAIN} +short | grep spf1 | tr -d '"')
if echo "${SPF_RECORD}" | grep -q "\-all"; then
    echo "✅ SPF policy has hard fail (-all)"
else
    echo "❌ SPF policy should have hard fail (-all)"
    exit 1
fi

# Validate DNSSEC
echo "Checking DNSSEC..."
if dig @${NAMESERVER} DS ${DOMAIN} | grep -q "DS"; then
    echo "✅ DNSSEC enabled"
else
    echo "❌ DNSSEC not configured"
    exit 1
fi

echo "🎉 All DNS security checks passed for ${DOMAIN}"
```

#### check-project-conflicts.sh
```bash
#!/bin/bash
# Check for DNS conflicts with external projects

set -euo pipefail

RESTRICTED_PATTERNS=(
    "@" "www" "mail" "email" "mx" "ns" "dns" 
    "autoconfig" "autodiscover" "lyncdiscover"
    "sip" "dmarc" "spf" "txt" "caa"
)

echo "🔍 Checking for DNS record conflicts..."

for domain_file in *.tf; do
    if grep -q "dns_records\|txt_records\|mx_records\|srv_records" "${domain_file}"; then
        domain=$(basename "${domain_file}" .tf | tr '-' '.')
        
        echo "Checking ${domain}..."
        
        # Extract DNS record names from Terraform files
        record_names=$(grep -E '^\s*"[^"]+"\s*=' "${domain_file}" | sed 's/.*"\([^"]*\)".*/\1/')
        
        for record in ${record_names}; do
            for pattern in "${RESTRICTED_PATTERNS[@]}"; do
                if [[ "${record}" == "${pattern}"* ]] || [[ "${record}" == *"${pattern}" ]]; then
                    echo "❌ Conflict detected: ${record} matches restricted pattern ${pattern}"
                    exit 1
                fi
            done
        done
    fi
done

echo "✅ No DNS conflicts detected"
```

## 📊 Monitoring & Metrics

### Key Performance Indicators (KPIs)

1. **Security Metrics:**
   - DNSSEC coverage: 100% (all domains)
   - CAA record coverage: Target 100%
   - DMARC p=reject coverage: Target 100%
   - SSL certificate validity monitoring

2. **Operational Metrics:**
   - DNS query response time < 50ms
   - Zone propagation time < 5 minutes
   - Configuration deployment success rate > 99%
   - External project onboarding time < 1 hour

3. **Compliance Metrics:**
   - Security scan pass rate: 100%
   - DNS validation pass rate: 100%
   - Domain expiration monitoring: 30+ days notice
   - Token rotation compliance: Annual

### Alerting Thresholds

```hcl
# Monitoring thresholds
variable "alert_thresholds" {
  description = "Alerting thresholds for DNS monitoring"
  type = object({
    dns_response_time_ms     = number
    certificate_expiry_days  = number
    domain_expiry_days      = number
    failed_queries_threshold = number
  })
  default = {
    dns_response_time_ms     = 100
    certificate_expiry_days  = 30
    domain_expiry_days      = 30
    failed_queries_threshold = 50
  }
}
```

## 🚀 Migration Strategy

### Phase Implementation Order

1. **Week 1**: Security enhancements (CAA, BIMI, validation scripts)
2. **Week 2**: Environment separation and enhanced monitoring
3. **Month 1**: Project access control framework
4. **Month 2**: Automated testing and CI/CD pipeline
5. **Quarter 1**: Advanced analytics and state management security
6. **Ongoing**: Quarterly reviews and continuous improvements

### Risk Mitigation

- All changes will be tested in development environment first
- Gradual rollout with canary deployments
- Comprehensive backup and rollback procedures
- External project communication plan for changes
- Documentation updates with each phase

## 📝 Documentation Requirements

1. **Technical Documentation:**
   - Architecture diagrams
   - API token management guide
   - External project integration guide
   - Incident response procedures

2. **Operational Documentation:**
   - Domain renewal procedures
   - Security incident playbooks
   - Monitoring and alerting setup
   - Disaster recovery procedures

## 🔄 Maintenance Schedule

- **Daily**: Automated security scans and validation
- **Weekly**: DNS performance metrics review
- **Monthly**: Certificate and domain expiration checks
- **Quarterly**: Security policy reviews and updates
- **Annually**: API token rotation and access audit

---

*This roadmap will be updated quarterly to reflect changing requirements and security best practices.*