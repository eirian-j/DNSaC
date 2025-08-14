# DNSaC Multi-Domain Outputs
# Consolidated outputs for all managed domains

# eirian.io Outputs
output "eirian_io" {
  description = "eirian.io domain configuration and status"
  value       = module.eirian_io.domain_config
}

output "eirian_io_zone_id" {
  description = "eirian.io CloudFlare zone ID"
  value       = module.eirian_io.zone_id
}

output "eirian_io_name_servers" {
  description = "eirian.io CloudFlare name servers"
  value       = module.eirian_io.name_servers
}

output "eirian_io_dnssec_ds_record" {
  description = "eirian.io DS record for parent zone delegation"
  value       = module.eirian_io.dnssec_ds_record
}

# eirianconsulting.com Outputs
output "eirianconsulting_com" {
  description = "eirianconsulting.com domain configuration and status"
  value       = module.eirianconsulting_com.domain_config
}

output "eirianconsulting_com_zone_id" {
  description = "eirianconsulting.com CloudFlare zone ID"
  value       = module.eirianconsulting_com.zone_id
}

output "eirianconsulting_com_name_servers" {
  description = "eirianconsulting.com CloudFlare name servers"
  value       = module.eirianconsulting_com.name_servers
}

# myrisk.ai Outputs
output "myrisk_ai" {
  description = "myrisk.ai domain configuration and status"
  value       = module.myrisk_ai.domain_config
}

output "myrisk_ai_zone_id" {
  description = "myrisk.ai CloudFlare zone ID"
  value       = module.myrisk_ai.zone_id
}

output "myrisk_ai_name_servers" {
  description = "myrisk.ai CloudFlare name servers"
  value       = module.myrisk_ai.name_servers
}

# myrisk.now Outputs
output "myrisk_now" {
  description = "myrisk.now domain configuration and status"
  value       = module.myrisk_now.domain_config
}

output "myrisk_now_zone_id" {
  description = "myrisk.now CloudFlare zone ID"
  value       = module.myrisk_now.zone_id
}

output "myrisk_now_name_servers" {
  description = "myrisk.now CloudFlare name servers"
  value       = module.myrisk_now.name_servers
}

# jwalter.eu Outputs
output "jwalter_eu" {
  description = "jwalter.eu domain configuration and status"
  value       = module.jwalter_eu.domain_config
}

output "jwalter_eu_zone_id" {
  description = "jwalter.eu CloudFlare zone ID"
  value       = module.jwalter_eu.zone_id
}

output "jwalter_eu_name_servers" {
  description = "jwalter.eu CloudFlare name servers"
  value       = module.jwalter_eu.name_servers
}

# walter.sg Outputs
output "walter_sg" {
  description = "walter.sg domain configuration and status"
  value       = module.walter_sg.domain_config
}

output "walter_sg_zone_id" {
  description = "walter.sg CloudFlare zone ID"
  value       = module.walter_sg.zone_id
}

output "walter_sg_name_servers" {
  description = "walter.sg CloudFlare name servers"
  value       = module.walter_sg.name_servers
}

# Consolidated Outputs
output "all_domains" {
  description = "All managed domains configuration summary"
  value = {
    "eirian.io" = {
      zone_id      = module.eirian_io.zone_id
      name_servers = module.eirian_io.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
    "eirianconsulting.com" = {
      zone_id      = module.eirianconsulting_com.zone_id
      name_servers = module.eirianconsulting_com.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
    "myrisk.ai" = {
      zone_id      = module.myrisk_ai.zone_id
      name_servers = module.myrisk_ai.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
    "myrisk.now" = {
      zone_id      = module.myrisk_now.zone_id
      name_servers = module.myrisk_now.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
    "jwalter.eu" = {
      zone_id      = module.jwalter_eu.zone_id
      name_servers = module.jwalter_eu.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
    "walter.sg" = {
      zone_id      = module.walter_sg.zone_id
      name_servers = module.walter_sg.name_servers
      ssl_mode     = "strict"
      proxy_enabled = true
    }
  }
}

# Name Server Summary for Easy Registrar Configuration
output "nameserver_configuration" {
  description = "CloudFlare name servers for each domain (for registrar configuration)"
  value = {
    "eirian.io"            = module.eirian_io.name_servers
    "eirianconsulting.com" = module.eirianconsulting_com.name_servers
    "myrisk.ai"            = module.myrisk_ai.name_servers
    "myrisk.now"           = module.myrisk_now.name_servers
    "jwalter.eu"           = module.jwalter_eu.name_servers
    "walter.sg"            = module.walter_sg.name_servers
  }
}

# DNSSEC DS Records for Parent Zone Delegation
output "dnssec_ds_records" {
  description = "DS records for all domains (for registrar DNSSEC configuration)"
  value = {
    "eirian.io"            = module.eirian_io.dnssec_ds_record
    "eirianconsulting.com" = module.eirianconsulting_com.dnssec_ds_record
    "myrisk.ai"            = module.myrisk_ai.dnssec_ds_record
    "myrisk.now"           = module.myrisk_now.dnssec_ds_record
    "jwalter.eu"           = module.jwalter_eu.dnssec_ds_record
    "walter.sg"            = module.walter_sg.dnssec_ds_record
  }
  sensitive = false
}

# Notification Policy IDs
output "notification_policies" {
  description = "CloudFlare notification policy IDs for monitoring"
  value = {
    ssl_certificate_expiry = cloudflare_notification_policy.ssl_certificate_expiry.id
    origin_ssl_events      = cloudflare_notification_policy.origin_ssl_events.id
    ssl_validation_errors  = cloudflare_notification_policy.ssl_validation_errors.id
    eirian_io_critical     = cloudflare_notification_policy.eirian_io_critical.id
    business_domains       = cloudflare_notification_policy.business_domains.id
  }
}