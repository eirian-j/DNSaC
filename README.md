# DNSaC - DNS as Code for eirian.io

This Terraform configuration manages the `eirian.io` domain on CloudFlare with secure, project-scoped DNS record management.

## Features

- **Complete Office 365/Outlook Integration**: Pre-configured DNS records for email, Teams, and Skype services
- **Central Domain Management**: Core DNS records (root A, www, MX, SPF, DKIM) managed centrally
- **Project Isolation**: Projects can only create DNS records in allowed subdomain patterns
- **Security Controls**: Comprehensive firewall rules, rate limiting, and bot protection
- **CloudFlare Optimization**: Zone settings optimized for performance and security
- **Validation**: Automated validation of subdomain patterns and record types
- **Reusable Module**: Projects can use the `project-dns` module for consistent DNS management

## Architecture

```
DNSaC (Central)
├── Core DNS Records
│   ├── Root A records (31.43.160.6, 31.43.161.6)
│   ├── WWW CNAME (sites.framer.app)
│   ├── Office 365/Outlook (MX, autodiscover, DKIM, SRV)
│   └── Security (SPF, verification)
├── CloudFlare Settings (SSL, caching, performance)
├── Security Rules (firewall, rate limiting, bot protection)
├── API Token Generation (limited scope)
└── Project Configuration

Projects (Individual)
├── Use project-dns module
├── Limited to allowed subdomains (*.dev, *.staging, api)
└── Cannot affect core records
```

## Setup

1. **Initial Setup**:
```bash
# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# - CloudFlare API token (with Zone:Read and DNS:Edit permissions)
# - Domain configuration
# - Allowed project IPs and subdomains
```

2. **Deploy DNS Infrastructure**:
```bash
terraform init
terraform plan
terraform apply
```

## Project Integration

Projects can create DNS records using the provided module:

```hcl
module "my_project_dns" {
  source = "path/to/DNSaC/modules/project-dns"

  zone_id           = data.terraform_remote_state.dns.outputs.zone_id
  project_name      = "my-project"
  subdomain         = "myapp.dev"
  type             = "A"
  value            = "192.168.1.100"
  allowed_subdomains = data.terraform_remote_state.dns.outputs.project_dns_config.allowed_subdomains
}
```

See `examples/project-usage/` for complete examples.

## Security Model

### Access Control
- **Central DNSaC**: Full CloudFlare API token with all permissions
- **Projects**: Limited API token with:
  - Zone:Read permission (read zone info)
  - DNS:Edit permission (create/update/delete DNS records only)
  - IP address restrictions
  - Time-limited tokens (1 year expiry)

### Subdomain Restrictions
Projects can only create records matching allowed patterns:
- `*.dev` - Development environments
- `*.staging` - Staging environments  
- `*.test` - Test environments
- `api` - API endpoints
- `app` - Application endpoints

### Protected Records
Core records are managed centrally and cannot be modified by projects:
- Root A record (`eirian.io`)
- WWW CNAME (`www.eirian.io`)
- MX records (email)
- SPF/DMARC records

## Configuration

### Core Variables
- `cloudflare_api_token`: Full-permission CloudFlare API token
- `domain_name`: Domain to manage (default: `eirian.io`)
- `root_ip`: IP for root A record
- `allowed_subdomains`: Patterns projects can use
- `allowed_project_ips`: IP ranges for project API access

### Project Variables
- `project_api_token`: Limited CloudFlare API token
- `subdomain`: Subdomain to create (must match allowed patterns)
- `type`: DNS record type (A, AAAA, CNAME, TXT, MX, SRV)
- `value`: DNS record value

## Usage Examples

### Central DNS Management
```bash
# Deploy core infrastructure
terraform apply

# View zone information
terraform output zone_id
terraform output name_servers
```

### Project DNS Records
```bash
# In project directory
cd examples/project-usage/
terraform init
terraform apply -var="project_api_token=limited-token-here"
```

## Configuration

### Core Variables
- `cloudflare_api_token`: Full-permission CloudFlare API token
- `domain_name`: Domain to manage (default: `eirian.io`)
- `ssl_mode`: SSL configuration (flexible, full, strict)
- `dmarc_record`: Optional DMARC policy

### Security Variables
- `enable_geo_blocking`: Challenge requests from suspicious countries
- `api_rate_limit_threshold`: Rate limit for API endpoints (default: 50/min)
- `enable_general_rate_limit`: Enable domain-wide rate limiting

### Project Variables
- `project_api_token`: Limited CloudFlare API token
- `subdomain`: Subdomain to create (must match allowed patterns)
- `type`: DNS record type (A, AAAA, CNAME, TXT, MX, SRV)
- `value`: DNS record value

## DNS Records Managed

### Office 365/Outlook Integration
- **MX**: `eirian-io.mail.protection.outlook.com` (priority 0)
- **Autodiscover**: `autodiscover.outlook.com`
- **DKIM**: Two selectors for email authentication
- **SRV**: Teams/Skype connectivity records
- **SPF**: Office 365 email authentication

### Core Domain Records
- **Root A**: Dual A records (31.43.160.6, 31.43.161.6)
- **WWW**: Points to Framer hosting (sites.framer.app)
- **Verification**: Microsoft domain verification

## Best Practices

1. **API Token Security**:
   - Use separate tokens for central management vs projects
   - Regularly rotate API tokens
   - Restrict IP access to known networks

2. **Subdomain Naming**:
   - Use environment-based patterns (`*.dev`, `*.staging`)
   - Include project name in subdomain when possible
   - Keep subdomains descriptive and organized

3. **Record Management**:
   - Set appropriate TTL values (300s for dev, higher for prod)
   - Use comments to document record purpose
   - Coordinate with central team for new subdomain patterns

4. **Security Configuration**:
   - Start with `ssl_mode = "flexible"` and upgrade gradually
   - Enable geo-blocking only if experiencing issues from specific regions
   - Monitor rate limiting logs before enabling strict limits

## Troubleshooting

### Common Issues
- **Subdomain not allowed**: Check `allowed_subdomains` patterns
- **API permission denied**: Verify token permissions and IP restrictions
- **Zone not found**: Ensure domain exists in CloudFlare account

### Validation
```bash
# Test subdomain pattern matching
terraform plan  # Will show validation errors if patterns don't match

# Verify API token permissions
terraform apply  # Will fail if token lacks required permissions
```