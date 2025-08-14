# Domain Management Module for DNSaC
# Manages a single domain with zones, DNS records, and SSL settings

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

# CloudFlare Zone
resource "cloudflare_zone" "domain" {
  account_id = var.cloudflare_account_id
  zone       = var.domain_name
  plan       = var.plan
  type       = "full"
}

# Zone Settings Override
resource "cloudflare_zone_settings_override" "domain_settings" {
  zone_id = cloudflare_zone.domain.id

  settings {
    # SSL Configuration
    ssl                         = var.ssl_mode
    always_use_https            = var.always_use_https ? "on" : "off"
    automatic_https_rewrites    = var.automatic_https_rewrites ? "on" : "off"
    
    # Security Settings
    security_level             = var.security_level
    browser_check              = var.browser_check ? "on" : "off"
    challenge_ttl              = var.challenge_ttl
    
    # Performance Settings  
    brotli                     = var.brotli_compression ? "on" : "off"
    early_hints                = var.early_hints ? "on" : "off"
    http3                      = var.http3 ? "on" : "off"
    zero_rtt                   = var.zero_rtt ? "on" : "off"
    
    # Caching Settings
    browser_cache_ttl          = var.browser_cache_ttl
    cache_level                = var.cache_level
    
    # Development Settings
    development_mode           = var.development_mode ? "on" : "off"
    
    # Privacy Settings
    privacy_pass               = var.privacy_pass ? "on" : "off"
    
    # Other Settings
    # rocket_loader              = var.rocket_loader  # Disabled for free plan compatibility
    opportunistic_encryption   = var.opportunistic_encryption ? "on" : "off"
    ip_geolocation             = var.ip_geolocation ? "on" : "off"
    email_obfuscation          = var.email_obfuscation ? "on" : "off"
    server_side_exclude        = var.server_side_exclude ? "on" : "off"
    hotlink_protection         = var.hotlink_protection ? "on" : "off"
    
    # Rate Limiting (if supported by plan)
    dynamic "security_header" {
      for_each = var.enable_security_headers ? [1] : []
      content {
        enabled = true
      }
    }
  }
}

# DNSSEC Configuration
resource "cloudflare_zone_dnssec" "domain" {
  zone_id = cloudflare_zone.domain.id
}

data "cloudflare_zone_dnssec" "domain" {
  zone_id = cloudflare_zone.domain.id
  depends_on = [cloudflare_zone_dnssec.domain]
}

# DNS Records - Root A Records
resource "cloudflare_record" "root_a" {
  count = length(var.root_a_records)
  
  zone_id = cloudflare_zone.domain.id
  name    = "@"
  content = var.root_a_records[count.index]
  type    = "A"
  ttl     = var.proxy_root_records ? 1 : var.default_ttl
  proxied = var.proxy_root_records
  comment = "Root A record ${count.index + 1} for ${var.domain_name} - ${var.proxy_root_records ? "Proxied" : "DNS-only"}"
}

# WWW CNAME Record
resource "cloudflare_record" "www_cname" {
  count = var.www_cname_target != "" ? 1 : 0
  
  zone_id = cloudflare_zone.domain.id
  name    = "www"
  content = var.www_cname_target
  type    = "CNAME"
  ttl     = var.proxy_www_record ? 1 : var.default_ttl
  proxied = var.proxy_www_record
  comment = "WWW CNAME for ${var.domain_name} - ${var.proxy_www_record ? "Proxied" : "DNS-only"}"
}

# Custom DNS Records
resource "cloudflare_record" "custom" {
  for_each = var.dns_records
  
  zone_id  = cloudflare_zone.domain.id
  name     = each.value.name
  content  = each.value.content
  type     = each.value.type
  ttl      = coalesce(each.value.proxied, false) ? 1 : coalesce(each.value.ttl, var.default_ttl)
  priority = each.value.priority
  proxied  = coalesce(each.value.proxied, false)
  comment  = "Custom ${each.value.type} record: ${each.key} for ${var.domain_name}"
}

# MX Records
resource "cloudflare_record" "mx" {
  for_each = var.mx_records
  
  zone_id  = cloudflare_zone.domain.id
  name     = each.value.name
  content  = each.value.content
  type     = "MX"
  ttl      = coalesce(each.value.ttl, var.default_ttl)
  priority = each.value.priority
  comment  = "MX record: ${each.key} for ${var.domain_name}"
}

# TXT Records
resource "cloudflare_record" "txt" {
  for_each = var.txt_records
  
  zone_id = cloudflare_zone.domain.id
  name    = each.value.name
  content = each.value.content
  type    = "TXT"
  ttl     = coalesce(each.value.ttl, var.default_ttl)
  comment = "TXT record: ${each.key} for ${var.domain_name}"
}

# SRV Records  
resource "cloudflare_record" "srv" {
  for_each = var.srv_records
  
  zone_id = cloudflare_zone.domain.id
  name    = each.value.name
  type    = "SRV"
  ttl     = coalesce(each.value.ttl, 1800)
  comment = "SRV record: ${each.key} for ${var.domain_name}"
  
  data {
    priority = each.value.priority
    weight   = each.value.weight
    port     = each.value.port
    target   = each.value.target
  }
}

# CAA Records (Certificate Authority Authorization)
resource "cloudflare_record" "caa" {
  for_each = var.enable_caa_records ? var.caa_records : {}
  
  zone_id  = cloudflare_zone.domain.id
  name     = "@"
  type     = "CAA"
  ttl      = coalesce(each.value.ttl, var.default_ttl)
  comment  = "CAA record: ${each.key} for ${var.domain_name} - Certificate authority authorization"
  
  data {
    flags = each.value.flags
    tag   = each.value.tag
    value = each.value.value
  }
}

# Local validation for DNS conflicts
locals {
  # Extract all DNS record names being created
  dns_record_names = concat(
    [for k, v in var.dns_records : v.name],
    [for k, v in var.txt_records : v.name],
    [for k, v in var.mx_records : v.name],
    [for k, v in var.srv_records : v.name],
    var.www_cname_target != "" ? ["www"] : []
  )
  
  # Check for conflicts with restricted patterns
  restricted_conflicts = var.validate_dns_conflicts ? [
    for name in local.dns_record_names :
    name if contains(var.project_subdomain_patterns.restricted, name) ||
           contains(var.project_subdomain_patterns.restricted, "${name}*") ||
           startswith(name, "_")
  ] : []
  
  # Validation message
  validation_errors = length(local.restricted_conflicts) > 0 ? [
    "DNS record name conflicts detected with restricted patterns: ${join(", ", local.restricted_conflicts)}"
  ] : []
}

# Validation check - will fail deployment if conflicts detected
resource "terraform_data" "dns_validation" {
  count = var.validate_dns_conflicts && length(local.validation_errors) > 0 ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: ${local.validation_errors[0]}' && exit 1"
  }
}