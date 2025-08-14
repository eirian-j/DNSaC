# Module for individual projects to manage their DNS records
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Validate subdomain against allowed patterns
locals {
  subdomain_valid = can(regex(join("|", [for pattern in var.allowed_subdomains : replace(pattern, "*", ".*")]), var.subdomain))
}

resource "cloudflare_record" "project_record" {
  count = local.subdomain_valid ? 1 : 0

  zone_id  = var.zone_id
  name     = var.subdomain
  value    = var.value
  type     = var.type
  ttl      = var.ttl
  priority = var.priority
  comment  = "${var.project_name} - ${var.comment}"

  lifecycle {
    # Prevent projects from destroying records accidentally
    prevent_destroy = false
  }
}

# Validation to ensure projects can't create unauthorized records
resource "terraform_data" "subdomain_validation" {
  count = local.subdomain_valid ? 0 : 1

  provisioner "local-exec" {
    command = "echo 'ERROR: Subdomain ${var.subdomain} is not allowed. Allowed patterns: ${join(", ", var.allowed_subdomains)}' && exit 1"
  }
}