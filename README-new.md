# DNSaC - Multi-Domain DNS as Code

**Enterprise-grade DNS management for multiple domains using Terraform and CloudFlare**

## 🏗️ Architecture

DNSaC manages multiple domains through a modular, scalable architecture:

```
DNSaC/
├── main.tf                    # CloudFlare provider & shared resources
├── variables.tf               # Global variables
├── outputs.tf                 # All domain outputs  
├── notifications.tf           # Multi-domain notifications
├── terraform.tfvars           # Your configuration (not in git)
├── terraform.tfvars.example   # Configuration template
├── domains/                   # Individual domain configurations
│   ├── eirian-io.tf          # eirian.io (primary business domain)
│   ├── eirianconsulting-com.tf   # eirianconsulting.com (consulting)
│   ├── myrisk-ai.tf          # myrisk.ai (AI applications)
│   ├── myrisk-now.tf         # myrisk.now (rapid deployment)
│   ├── jwalter-eu.tf         # jwalter.eu (EU personal domain)
│   └── walter-sg.tf          # walter.sg (Singapore domain)
└── modules/
    └── domain/               # Reusable domain module
        ├── main.tf           # Domain resources
        ├── variables.tf      # Domain variables
        └── outputs.tf        # Domain outputs
```

## 🚀 Managed Domains

| Domain | Purpose | Features | SSL | Proxy |
|--------|---------|----------|-----|-------|
| **eirian.io** | Primary business domain | Office 365, DNSSEC, full DNS | Strict | ✅ |
| **eirianconsulting.com** | Professional consulting | Business optimization | Strict | ✅ |
| **myrisk.ai** | AI applications | Enhanced security, API endpoints | Strict | ✅ |
| **myrisk.now** | Rapid deployment | Dev/staging subdomains | Strict | ✅ |
| **jwalter.eu** | EU personal domain | GDPR-compliant, portfolio | Strict | ✅ |
| **walter.sg** | Singapore domain | Asia-Pacific optimized | Strict | ✅ |

## ⚡ Quick Start

### 1. Prerequisites
- [Terraform](https://www.terraform.io/) >= 1.0
- CloudFlare account with API token
- Domain registrar access for nameserver updates

### 2. Configuration
```bash
# Clone and setup
git clone <repository-url>
cd DNSaC

# Configure your settings
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your CloudFlare credentials
```

### 3. Deploy
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy all domains
terraform apply
```

### 4. Update Nameservers
After deployment, update nameservers at your domain registrars:
```bash
# Get nameserver information
terraform output nameserver_configuration
```

## 🔧 Key Features

### **Multi-Domain Management**
- ✅ Centralized configuration across 6 domains
- ✅ Consistent SSL/proxy settings
- ✅ Domain-specific customizations
- ✅ Modular, reusable architecture

### **Security & Performance**
- ✅ **SSL Strict Mode**: Certificate validation required
- ✅ **CloudFlare Proxy**: DDoS protection, global CDN
- ✅ **DNSSEC**: Domain security extensions
- ✅ **Security Headers**: Enhanced browser security
- ✅ **Performance Optimization**: HTTP/3, Brotli, Early Hints

### **Monitoring & Alerts**
- ✅ **SSL Certificate Monitoring**: Expiry and validation alerts
- ✅ **Multi-Domain Notifications**: Centralized alerting
- ✅ **Business-Critical Alerts**: Priority alerts for key domains
- ✅ **Email Integration**: Alerts to cloudflare.alerts@eirian.io

### **Professional DNS**
- ✅ **Office 365 Integration**: Full email/Teams setup (eirian.io)
- ✅ **API Endpoints**: Dedicated subdomains for applications
- ✅ **Development Environments**: Staging/dev/test subdomains
- ✅ **Geographic Optimization**: Region-specific settings

---

**DNSaC** - Professional DNS management made simple 🚀