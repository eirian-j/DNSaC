output "zone_id" {
  description = "CloudFlare zone ID for eirian.io"
  value       = data.cloudflare_zone.eirian_io.id
}

output "zone_name" {
  description = "Zone name"
  value       = data.cloudflare_zone.eirian_io.name
}

output "name_servers" {
  description = "CloudFlare name servers for the zone"
  value       = data.cloudflare_zone.eirian_io.name_servers
}

output "dnssec_status" {
  description = "DNSSEC status and configuration for the zone"
  value = {
    status         = data.cloudflare_zone_dnssec.eirian_io.status
    algorithm      = data.cloudflare_zone_dnssec.eirian_io.algorithm
    digest         = data.cloudflare_zone_dnssec.eirian_io.digest
    key_tag        = data.cloudflare_zone_dnssec.eirian_io.key_tag
    public_key     = data.cloudflare_zone_dnssec.eirian_io.public_key
  }
  sensitive = true
}

output "dnssec_ds_record" {
  description = "DS record for parent zone delegation"
  value       = data.cloudflare_zone_dnssec.eirian_io.ds
  sensitive   = false
}

# Outputs for project integration
output "project_dns_config" {
  description = "Configuration data for projects to use when creating DNS records"
  value = {
    zone_id           = data.cloudflare_zone.eirian_io.id
    domain_name       = var.domain_name
    allowed_subdomains = var.allowed_subdomains
    default_ttl       = var.default_ttl
  }
}