# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DNSaC (DNS as Code) is a Terraform-based solution for managing the `eirian.io` domain on CloudFlare. It provides centralized DNS management with secure project-scoped access controls, allowing other projects to manage their DNS records without affecting core domain infrastructure.

## Development Commands

### Terraform Operations
```bash
# Initialize Terraform (first time setup)
terraform init

# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
terraform output zone_id
```

### Setup Commands
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration with your values
# Required: cloudflare_api_token, domain_name, root_ip
```

## Architecture

### Core Components
- **main.tf**: Primary CloudFlare provider and core DNS records (root, www, MX, SPF, DMARC)
- **projects.tf**: Project-specific DNS record management with validation
- **modules/project-dns/**: Reusable module for projects to create DNS records
- **variables.tf**: Configuration variables with validation
- **outputs.tf**: Exports zone information and project configuration data

### Security Model
- **Central Management**: Full CloudFlare API access for core infrastructure
- **Project Access**: Limited API tokens with IP restrictions and subdomain pattern validation
- **Isolation**: Projects can only create records in allowed subdomain patterns (`*.dev`, `*.staging`, `api`, etc.)

### File Structure
```
.
├── main.tf                  # Core DNS records (Office 365, root A, www)
├── projects.tf              # Project DNS record management
├── cloudflare-settings.tf   # Zone settings, SSL, performance optimization
├── firewall.tf              # Security rules, rate limiting, bot protection
├── variables.tf             # Input variables with validation
├── outputs.tf               # Output values for project integration  
├── versions.tf              # Terraform and provider version constraints
├── modules/
│   └── project-dns/         # Reusable module for project DNS records
├── examples/
│   └── project-usage/       # Example project integration
└── terraform.tfvars.example # Configuration template
```

## Key Variables
- `cloudflare_api_token`: Full CloudFlare API token (sensitive)
- `domain_name`: Domain to manage (default: "eirian.io")
- `ssl_mode`: SSL configuration ("flexible", "full", "strict")
- `enable_geo_blocking`: Challenge suspicious countries
- `api_rate_limit_threshold`: API rate limiting (default: 50/min)
- `allowed_subdomains`: Patterns projects can create (["*.dev", "*.staging", "api"])
- `allowed_project_ips`: IP ranges for project API access

## DNS Records Managed
- **Office 365 Integration**: Complete email, Teams, and authentication setup
- **Root A Records**: Dual A records (31.43.160.6, 31.43.161.6)
- **WWW CNAME**: Points to Framer hosting (sites.framer.app)
- **Security Records**: SPF, DKIM, Microsoft verification

## Security Features
- **Firewall Rules**: Block bad bots and attack patterns
- **Rate Limiting**: API and general domain protection
- **SSL/TLS**: Force HTTPS with modern TLS settings
- **Performance**: Optimized caching, compression, minification

## Project Integration
Projects use the `project-dns` module with limited API tokens:
- Subdomain validation against allowed patterns
- Record type restrictions (A, AAAA, CNAME, TXT, MX, SRV)
- TTL limits (60-86400 seconds)
- Cannot modify core domain records