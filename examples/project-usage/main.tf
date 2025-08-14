# Example: How a project would use the DNS module

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  # Projects should use the limited API token
  api_token = var.project_api_token
}

# Get DNS configuration from the main DNSaC setup
data "terraform_remote_state" "dns" {
  backend = "local"
  config = {
    path = "../../terraform.tfstate"
  }
}

# Create DNS record for this project
module "my_project_dns" {
  source = "../../modules/project-dns"

  zone_id           = data.terraform_remote_state.dns.outputs.zone_id
  project_name      = "my-awesome-project"
  subdomain         = "myapp.dev"
  type             = "A"
  value            = "192.168.1.150"
  ttl              = 300
  comment          = "My awesome application development environment"
  allowed_subdomains = data.terraform_remote_state.dns.outputs.project_dns_config.allowed_subdomains
}

# Example: Multiple records for a single project
module "my_project_api_dns" {
  source = "../../modules/project-dns"

  zone_id           = data.terraform_remote_state.dns.outputs.zone_id
  project_name      = "my-awesome-project"
  subdomain         = "api.dev"
  type             = "A"
  value            = "192.168.1.151"
  ttl              = 300
  comment          = "My awesome project API endpoint"
  allowed_subdomains = data.terraform_remote_state.dns.outputs.project_dns_config.allowed_subdomains
}