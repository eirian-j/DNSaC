# DNSaC - Multi-Domain DNS as Code
# CloudFlare provider configuration and shared resources

terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# CloudFlare Provider Configuration
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Include all domain configurations
# Domain configurations are stored in separate files for better organization
# Each domain is managed through the reusable domain module