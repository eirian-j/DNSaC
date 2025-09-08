variable "zone_id" {
  description = "CloudFlare zone ID"
  type        = string
}

variable "domain" {
  description = "Base domain name (e.g., eirian.io)"
  type        = string
}

variable "project" {
  description = "Project name (must be from authorized list)"
  type        = string

  validation {
    condition     = contains(["monika", "jarvis", "hal"], var.project)
    error_message = "Project must be one of: monika, jarvis, hal."
  }
}

variable "services" {
  description = "Map of services with their environments and configurations"
  type = map(object({
    environments = map(object({
      a_records = optional(list(object({
        ip_address = string
        ttl        = optional(number, 300)
        comment    = optional(string)
      })), [])
      aaaa_records = optional(list(object({
        ipv6_address = string
        ttl          = optional(number, 300)
        comment      = optional(string)
      })), [])
      cname_target  = optional(string) # For CNAME records pointing to the A record
      cname_ttl     = optional(number, 300)
      cname_proxied = optional(bool, true) # Whether to proxy CNAME through Cloudflare
      cname_comment = optional(string)
    }))
  }))

  validation {
    condition = alltrue([
      for service_name, service in var.services : alltrue([
        for env_name, env in service.environments :
        contains(["lab", "dev", "staging", "prod"], env_name)
      ])
    ])
    error_message = "Environment must be one of: lab, dev, staging, prod."
  }

  validation {
    condition = alltrue([
      for service_name, service in var.services : alltrue([
        for env_name, env in service.environments : alltrue([
          for a_record in coalesce(env.a_records, []) :
          can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", a_record.ip_address))
        ])
      ])
    ])
    error_message = "IP address must be a valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for service_name, service in var.services : alltrue([
        for env_name, env in service.environments : alltrue([
          for aaaa_record in coalesce(env.aaaa_records, []) :
          can(regex("^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))$", aaaa_record.ipv6_address))
        ])
      ])
    ])
    error_message = "IPv6 address must be valid."
  }

  validation {
    condition = alltrue([
      for service_name, service in var.services : alltrue([
        for env_name, env in service.environments : alltrue(flatten([
          [for a_record in coalesce(env.a_records, []) :
            !contains(["ttl"], keys(a_record)) || (a_record.ttl >= 60 && a_record.ttl <= 86400)
          ],
          [for aaaa_record in coalesce(env.aaaa_records, []) :
            !contains(["ttl"], keys(aaaa_record)) || (aaaa_record.ttl >= 60 && aaaa_record.ttl <= 86400)
          ]
        ]))
      ])
    ])
    error_message = "TTL must be between 60 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for service_name, service in var.services :
      length(service_name) > 0 && length(service_name) <= 63 && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", service_name))
    ])
    error_message = "Service name must be a valid DNS label (1-63 characters, lowercase alphanumeric and hyphens only, cannot start or end with hyphen)."
  }
}