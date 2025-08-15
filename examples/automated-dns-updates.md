# Automated DNS Updates for External Projects

## The Problem
When projects create/destroy resources, DNS must update IMMEDIATELY:
- New server deployed → DNS points to new IP instantly
- Server destroyed → DNS record removed automatically  
- Application moved → DNS updated without manual intervention

## Recommended Solution: Scoped CloudFlare API Tokens

### Architecture Overview
```
[Project Server] → [Deployment Script] → [CloudFlare API] → [DNS Updated]
                          ↓
                   [Validation Rules]
                   (Pattern matching)
```

## Step 1: Create Project-Specific API Tokens in DNSaC

```hcl
# Add to DNSaC: project-tokens.tf
resource "cloudflare_api_token" "n8n_project" {
  name = "n8n-automated-dns"
  
  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS:Edit"],
      data.cloudflare_api_token_permission_groups.all.zone["Zone:Read"]
    ]
    
    resources = {
      "com.cloudflare.api.account.zone.${module.eirian_io.zone_id}" = "*"
    }
  }
  
  # Critical: Restrict what records can be created
  condition {
    request_ip {
      in = var.n8n_server_ips  # Only from n8n infrastructure
    }
  }
}

# Output token for secure distribution
output "n8n_api_token" {
  value = cloudflare_api_token.n8n_project.value
  sensitive = true
}
```

## Step 2: Project Integration Scripts

### For Kubernetes/Docker Deployments:
```bash
#!/bin/bash
# deploy-with-dns.sh - Runs during deployment

SERVICE_NAME="n8n"
DOMAIN="eirian.io"
NEW_IP=$(kubectl get service $SERVICE_NAME -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
CLOUDFLARE_TOKEN="${CLOUDFLARE_N8N_TOKEN}"
ZONE_ID="${CLOUDFLARE_ZONE_ID}"

# Update DNS immediately after deployment
curl -X PUT "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "'${SERVICE_NAME}'",
    "content": "'${NEW_IP}'",
    "ttl": 1,
    "proxied": true
  }'
```

### For Terraform-Managed Projects:
```hcl
# In project's terraform (NOT DNSaC)
terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_dns_token  # Scoped token from DNSaC
}

# Automatically update DNS when server is created
resource "aws_instance" "n8n" {
  ami           = "ami-12345"
  instance_type = "t3.medium"
  
  provisioner "local-exec" {
    command = <<-EOT
      curl -X PUT "https://api.cloudflare.com/client/v4/zones/${var.zone_id}/dns_records/${var.record_id}" \
        -H "Authorization: Bearer ${var.cloudflare_dns_token}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"n8n","content":"${self.public_ip}","ttl":1,"proxied":true}'
    EOT
  }
  
  provisioner "local-exec" {
    when = destroy
    command = <<-EOT
      curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${var.zone_id}/dns_records/${var.record_id}" \
        -H "Authorization: Bearer ${var.cloudflare_dns_token}"
    EOT
  }
}
```

## Step 3: CloudFlare Custom Rules for Validation

Since tokens can't enforce subdomain patterns directly, use CloudFlare Rules:

```hcl
# In DNSaC: Add custom firewall rules
resource "cloudflare_ruleset" "dns_api_restrictions" {
  zone_id = module.eirian_io.zone_id
  name    = "DNS API Restrictions"
  kind    = "zone"
  phase   = "http_request_firewall_custom"
  
  rules {
    action = "block"
    expression = <<-EOT
      (http.request.uri.path contains "/dns_records" and 
       http.request.method eq "POST" and
       http.request.body.json.name in {"@" "www" "mail" "mx"})
    EOT
    description = "Block restricted DNS names via API"
  }
}
```

## Step 4: Real-World Implementation Examples

### Example 1: n8n with Auto-Scaling
```yaml
# n8n kubernetes deployment
apiVersion: v1
kind: Service
metadata:
  name: n8n
  annotations:
    # Triggers DNS update via webhook
    external-dns.alpha.kubernetes.io/hostname: n8n.eirian.io
    external-dns.alpha.kubernetes.io/ttl: "60"
spec:
  type: LoadBalancer
  ports:
    - port: 5678
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: n8n
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: n8n
        image: n8nio/n8n
        env:
        - name: WEBHOOK_URL
          value: "https://n8n.eirian.io"
      initContainers:
      - name: update-dns
        image: curlimages/curl
        command: 
        - sh
        - -c
        - |
          # Wait for LoadBalancer IP
          while [ -z "$LB_IP" ]; do
            LB_IP=$(kubectl get svc n8n -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
            sleep 5
          done
          # Update CloudFlare DNS
          curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
            -H "Authorization: Bearer $CF_TOKEN" \
            -d "{\"content\":\"$LB_IP\"}"
```

### Example 2: Grafana with Health Checks
```python
# grafana_dns_manager.py
import requests
import time
from kubernetes import client, config

class DNSManager:
    def __init__(self, cf_token, zone_id):
        self.cf_token = cf_token
        self.zone_id = zone_id
        self.cf_api = "https://api.cloudflare.com/client/v4"
        
    def update_dns(self, subdomain, ip_address):
        """Update DNS record immediately"""
        # Check if subdomain is allowed
        allowed_patterns = ['grafana', 'metrics', 'monitoring']
        if not any(subdomain.startswith(p) for p in allowed_patterns):
            raise ValueError(f"Subdomain {subdomain} not allowed")
            
        headers = {
            "Authorization": f"Bearer {self.cf_token}",
            "Content-Type": "application/json"
        }
        
        # Find existing record
        response = requests.get(
            f"{self.cf_api}/zones/{self.zone_id}/dns_records?name={subdomain}.eirian.io",
            headers=headers
        )
        
        if response.json()['result']:
            # Update existing
            record_id = response.json()['result'][0]['id']
            requests.put(
                f"{self.cf_api}/zones/{self.zone_id}/dns_records/{record_id}",
                headers=headers,
                json={"type": "A", "name": subdomain, "content": ip_address, "ttl": 1}
            )
        else:
            # Create new
            requests.post(
                f"{self.cf_api}/zones/{self.zone_id}/dns_records",
                headers=headers,
                json={"type": "A", "name": subdomain, "content": ip_address, "ttl": 1}
            )
    
    def cleanup_dns(self, subdomain):
        """Remove DNS record when service is destroyed"""
        headers = {"Authorization": f"Bearer {self.cf_token}"}
        
        response = requests.get(
            f"{self.cf_api}/zones/{self.zone_id}/dns_records?name={subdomain}.eirian.io",
            headers=headers
        )
        
        if response.json()['result']:
            record_id = response.json()['result'][0]['id']
            requests.delete(
                f"{self.cf_api}/zones/{self.zone_id}/dns_records/{record_id}",
                headers=headers
            )

# Usage in deployment script
if __name__ == "__main__":
    dns = DNSManager(
        cf_token=os.environ['CF_TOKEN'],
        zone_id=os.environ['CF_ZONE_ID']
    )
    
    # On deployment
    new_ip = deploy_grafana()  # Returns new server IP
    dns.update_dns('grafana', new_ip)
    
    # On teardown
    dns.cleanup_dns('grafana')
```

### Example 3: Docker Compose with DNS Sidecar
```yaml
# docker-compose.yml with automatic DNS updates
version: '3.8'

services:
  crewai:
    image: crewai:latest
    ports:
      - "8080:8080"
    environment:
      - SERVICE_NAME=crewai
    networks:
      - web
      
  dns-updater:
    image: cloudflare/cloudflare-dns-updater:latest
    environment:
      - CF_API_TOKEN=${CF_CREWAI_TOKEN}
      - CF_ZONE_ID=${CF_ZONE_ID}
      - SERVICE_NAME=crewai
      - DOMAIN=eirian.io
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: |
      sh -c '
      while true; do
        # Get container IP
        IP=$(docker inspect crewai | jq -r ".[0].NetworkSettings.Networks.web.IPAddress")
        
        # Update CloudFlare
        curl -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
          -H "Authorization: Bearer $CF_API_TOKEN" \
          -d "{\"content\":\"$IP\"}"
          
        sleep 60  # Check every minute
      done
      '
```

## Step 5: Monitoring & Validation

### DNSaC Monitors External Changes:
```hcl
# In DNSaC: monitoring.tf
resource "null_resource" "dns_compliance_check" {
  triggers = {
    always_run = timestamp()
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      # Check for unauthorized DNS records every hour
      RECORDS=$(curl -s -H "Authorization: Bearer ${var.cloudflare_api_token}" \
        "https://api.cloudflare.com/client/v4/zones/${module.eirian_io.zone_id}/dns_records")
      
      # Validate against rules
      echo "$RECORDS" | jq '.result[] | select(.name | test("^(mail|mx|@|www)"))'
      
      if [ $? -eq 0 ]; then
        echo "WARNING: Restricted DNS records detected!"
        # Send alert
      fi
    EOT
  }
}
```

## The Complete Flow

1. **Project deploys new resource** (e.g., new n8n container)
2. **Deployment script gets new IP** (from load balancer/container)
3. **Script calls CloudFlare API** (using scoped token)
4. **DNS updates immediately** (typically < 5 seconds)
5. **DNSaC validates periodically** (checks for violations)
6. **Alerts if rules broken** (notification to admins)

## Security Safeguards

### Token Permissions Matrix:
```
Project     | Can Create        | Cannot Create      | IP Restricted
------------|-------------------|-------------------|---------------
n8n         | n8n.*, n8n-api.* | @, www, mail, mx  | Yes (n8n servers)
grafana     | grafana.*, metrics.* | @, www, mail   | Yes (monitoring)
crewai      | crewai.*, ai.*   | @, www, mail      | Yes (AI cluster)
```

### Automatic Rollback on Violation:
```bash
#!/bin/bash
# Run by DNSaC every 5 minutes
VIOLATIONS=$(./check-dns-compliance.sh)

if [ ! -z "$VIOLATIONS" ]; then
  echo "Rolling back unauthorized changes..."
  terraform apply -auto-approve  # Revert to DNSaC state
  
  # Notify security team
  send-alert "DNS violation detected and reverted: $VIOLATIONS"
fi
```

## Benefits of This Approach

✅ **Immediate Updates**: DNS changes in seconds, not hours
✅ **No Manual Work**: Fully automated with deployments
✅ **Security Maintained**: Tokens can't modify critical records
✅ **Audit Trail**: All changes logged in CloudFlare
✅ **Self-Healing**: DNSaC can revert unauthorized changes

## Implementation Steps

1. **Create scoped tokens** in DNSaC for each project
2. **Distribute tokens** securely (Kubernetes secrets, HashiCorp Vault)
3. **Update deployment scripts** to include DNS updates
4. **Enable monitoring** to detect violations
5. **Test rollback procedures** to ensure safety

This gives projects the speed they need while maintaining security!