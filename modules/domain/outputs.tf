# Domain Module Outputs

output "zone_id" {
  description = "CloudFlare zone ID"
  value       = cloudflare_zone.domain.id
}

output "zone_name" {
  description = "Domain name"
  value       = cloudflare_zone.domain.zone
}

output "name_servers" {
  description = "CloudFlare name servers for the domain"
  value       = cloudflare_zone.domain.name_servers
}

output "zone_status" {
  description = "Zone status"
  value       = cloudflare_zone.domain.status
}

output "dnssec_status" {
  description = "DNSSEC status and configuration"
  value = {
    status     = data.cloudflare_zone_dnssec.domain.status
    algorithm  = data.cloudflare_zone_dnssec.domain.algorithm
    digest     = data.cloudflare_zone_dnssec.domain.digest
    key_tag    = data.cloudflare_zone_dnssec.domain.key_tag
    public_key = data.cloudflare_zone_dnssec.domain.public_key
  }
  sensitive = true
}

output "dnssec_ds_record" {
  description = "DS record for parent zone delegation"
  value       = data.cloudflare_zone_dnssec.domain.ds
  sensitive   = false
}

output "root_a_records" {
  description = "Root A record IDs and IPs"
  value = {
    for idx, record in cloudflare_record.root_a : idx => {
      id      = record.id
      content = record.content
      proxied = record.proxied
    }
  }
}

output "www_cname_record" {
  description = "WWW CNAME record details"
  value = length(cloudflare_record.www_cname) > 0 ? {
    id      = cloudflare_record.www_cname[0].id
    content = cloudflare_record.www_cname[0].content
    proxied = cloudflare_record.www_cname[0].proxied
  } : null
}

output "custom_dns_records" {
  description = "Custom DNS record details"
  value = {
    for key, record in cloudflare_record.custom : key => {
      id      = record.id
      name    = record.name
      content = record.content
      type    = record.type
      proxied = record.proxied
    }
  }
}

output "mx_records" {
  description = "MX record details"
  value = {
    for key, record in cloudflare_record.mx : key => {
      id       = record.id
      name     = record.name
      content  = record.content
      priority = record.priority
    }
  }
}

output "txt_records" {
  description = "TXT record details"
  value = {
    for key, record in cloudflare_record.txt : key => {
      id      = record.id
      name    = record.name
      content = record.content
    }
  }
}

output "srv_records" {
  description = "SRV record details"
  value = {
    for key, record in cloudflare_record.srv : key => {
      id   = record.id
      name = record.name
      data = record.data
    }
  }
}

output "domain_config" {
  description = "Domain configuration summary for external reference"
  value = {
    domain_name    = var.domain_name
    zone_id        = cloudflare_zone.domain.id
    name_servers   = cloudflare_zone.domain.name_servers
    ssl_mode       = var.ssl_mode
    proxy_enabled  = var.proxy_root_records
    dnssec_enabled = data.cloudflare_zone_dnssec.domain.status == "active"
    plan           = var.plan
  }
}