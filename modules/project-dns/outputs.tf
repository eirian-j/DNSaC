output "a_records" {
  description = "Map of A records created (service.project.env.domain.tld)"
  value = {
    for key, record in cloudflare_record.a_records : key => {
      id          = record.id
      hostname    = record.hostname
      name        = record.name
      value       = record.value
      ttl         = record.ttl
      service     = local.all_records[key].service
      environment = local.all_records[key].env
    }
  }
}

output "aaaa_records" {
  description = "Map of AAAA records created (service.project.env.domain.tld)"
  value = {
    for key, record in cloudflare_record.aaaa_records : key => {
      id          = record.id
      hostname    = record.hostname
      name        = record.name
      value       = record.value
      ttl         = record.ttl
      service     = local.all_records[key].service
      environment = local.all_records[key].env
    }
  }
}

output "cname_records" {
  description = "Map of CNAME records created (service-project-env.domain.tld)"
  value = {
    for key, record in cloudflare_record.cname_records : key => {
      id          = record.id
      hostname    = record.hostname
      name        = record.name
      target      = record.value
      ttl         = record.ttl
      service     = local.all_records[key].service
      environment = local.all_records[key].env
    }
  }
}

output "services_by_environment" {
  description = "Services organized by environment with their DNS records"
  value = {
    for env in distinct([for r in local.all_records : r.env]) : env => {
      services = distinct([for r in local.all_records : r.service if r.env == env])
      a_records = [
        for key, record in cloudflare_record.a_records :
        "${record.hostname} → ${record.value}"
        if local.all_records[key].env == env
      ]
      aaaa_records = [
        for key, record in cloudflare_record.aaaa_records :
        "${record.hostname} → ${record.value}"
        if local.all_records[key].env == env
      ]
      cname_records = [
        for key, record in cloudflare_record.cname_records :
        "${record.hostname} → ${record.value}"
        if local.all_records[key].env == env
      ]
    }
  }
}

output "record_count" {
  description = "Total number of DNS records created"
  value = {
    total         = length(cloudflare_record.a_records) + length(cloudflare_record.aaaa_records) + length(cloudflare_record.cname_records)
    a_records     = length(cloudflare_record.a_records)
    aaaa_records  = length(cloudflare_record.aaaa_records)
    cname_records = length(cloudflare_record.cname_records)
  }
}

output "project_info" {
  description = "Project configuration summary"
  value = {
    project  = var.project
    domain   = var.domain
    services = keys(var.services)
    environments = distinct(flatten([
      for service in var.services : keys(service.environments)
    ]))
  }
}