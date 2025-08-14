# Domain Module Variables

# Required Variables
variable "cloudflare_account_id" {
  description = "CloudFlare account ID"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Domain name to manage"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]?\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid domain format."
  }
}

# Zone Configuration
variable "plan" {
  description = "CloudFlare plan (free, pro, business, enterprise)"
  type        = string
  default     = "free"
  
  validation {
    condition     = contains(["free", "pro", "business", "enterprise"], var.plan)
    error_message = "Plan must be one of: free, pro, business, enterprise."
  }
}

# DNS Records Configuration
variable "root_a_records" {
  description = "List of A record IP addresses for root domain"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.root_a_records : can(cidrhost("${ip}/32", 0))
    ])
    error_message = "All root_a_records must be valid IPv4 addresses."
  }
}

variable "www_cname_target" {
  description = "CNAME target for www subdomain (empty to skip)"
  type        = string
  default     = ""
}

variable "dns_records" {
  description = "Custom DNS records"
  type = map(object({
    name     = string
    content  = string
    type     = string
    ttl      = optional(number)
    priority = optional(number)
    proxied  = optional(bool)
  }))
  default = {}
}

variable "mx_records" {
  description = "MX records for email"
  type = map(object({
    name     = string
    content  = string
    priority = number
    ttl      = optional(number)
  }))
  default = {}
}

variable "txt_records" {
  description = "TXT records for verification, SPF, DMARC, etc."
  type = map(object({
    name    = string
    content = string
    ttl     = optional(number)
  }))
  default = {}
}

variable "srv_records" {
  description = "SRV records for services"
  type = map(object({
    name     = string
    priority = number
    weight   = number
    port     = number
    target   = string
    ttl      = optional(number)
  }))
  default = {}
}

# SSL and Proxy Settings
variable "ssl_mode" {
  description = "SSL mode (off, flexible, full, strict)"
  type        = string
  default     = "strict"
  
  validation {
    condition     = contains(["off", "flexible", "full", "strict"], var.ssl_mode)
    error_message = "SSL mode must be one of: off, flexible, full, strict."
  }
}

variable "proxy_root_records" {
  description = "Enable CloudFlare proxy for root A records"
  type        = bool
  default     = true
}

variable "proxy_www_record" {
  description = "Enable CloudFlare proxy for www CNAME"
  type        = bool
  default     = false
}

# CloudFlare Settings
variable "default_ttl" {
  description = "Default TTL for DNS records"
  type        = number
  default     = 300
  
  validation {
    condition     = var.default_ttl >= 60 && var.default_ttl <= 86400
    error_message = "TTL must be between 60 and 86400 seconds."
  }
}

variable "always_use_https" {
  description = "Always use HTTPS"
  type        = bool
  default     = true
}

variable "automatic_https_rewrites" {
  description = "Automatic HTTPS rewrites"
  type        = bool
  default     = true
}

variable "security_level" {
  description = "Security level (essentially_off, low, medium, high, under_attack)"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["essentially_off", "low", "medium", "high", "under_attack"], var.security_level)
    error_message = "Security level must be one of: essentially_off, low, medium, high, under_attack."
  }
}

variable "browser_check" {
  description = "Enable browser integrity check"
  type        = bool
  default     = true
}

variable "challenge_ttl" {
  description = "Challenge TTL in seconds"
  type        = number
  default     = 1800
}

variable "brotli_compression" {
  description = "Enable Brotli compression"
  type        = bool
  default     = true
}

variable "early_hints" {
  description = "Enable Early Hints"
  type        = bool
  default     = true
}

variable "http3" {
  description = "Enable HTTP/3"
  type        = bool
  default     = true
}

variable "zero_rtt" {
  description = "Enable 0-RTT"
  type        = bool
  default     = true
}

variable "browser_cache_ttl" {
  description = "Browser cache TTL"
  type        = number
  default     = 14400
}

variable "cache_level" {
  description = "Cache level (aggressive, basic, simplified)"
  type        = string
  default     = "aggressive"
  
  validation {
    condition     = contains(["aggressive", "basic", "simplified"], var.cache_level)
    error_message = "Cache level must be one of: aggressive, basic, simplified."
  }
}

variable "development_mode" {
  description = "Enable development mode (bypass cache)"
  type        = bool
  default     = false
}

variable "privacy_pass" {
  description = "Enable Privacy Pass"
  type        = bool
  default     = true
}

variable "rocket_loader" {
  description = "Rocket Loader setting (off, manual, on)"
  type        = string
  default     = "off"  # Free plan limitation
  
  validation {
    condition     = contains(["off", "manual", "on"], var.rocket_loader)
    error_message = "Rocket Loader must be one of: off, manual, on."
  }
}

variable "opportunistic_encryption" {
  description = "Enable opportunistic encryption"
  type        = bool
  default     = true
}

variable "ip_geolocation" {
  description = "Enable IP geolocation"
  type        = bool
  default     = true
}

variable "email_obfuscation" {
  description = "Enable email obfuscation"
  type        = bool
  default     = true
}

variable "server_side_exclude" {
  description = "Enable server side exclude"
  type        = bool
  default     = true
}

variable "hotlink_protection" {
  description = "Enable hotlink protection"
  type        = bool
  default     = false  # Free plan limitation
}

variable "enable_security_headers" {
  description = "Enable security headers"
  type        = bool
  default     = true
}

# CAA Records Configuration
variable "caa_records" {
  description = "Certificate Authority Authorization records"
  type = map(object({
    flags = number
    tag   = string
    value = string
    ttl   = optional(number)
  }))
  default = {
    "letsencrypt" = {
      flags = 0
      tag   = "issue"
      value = "letsencrypt.org"
    }
    "cloudflare" = {
      flags = 0
      tag   = "issue"
      value = "comodoca.com"
    }
    "digicert" = {
      flags = 0
      tag   = "issue"
      value = "digicert.com"
    }
    "iodef" = {
      flags = 0
      tag   = "iodef"
      value = "mailto:security@eirian.io"
    }
  }
}

variable "enable_caa_records" {
  description = "Enable Certificate Authority Authorization records"
  type        = bool
  default     = true
}

# External Project Subdomain Validation
variable "project_subdomain_patterns" {
  description = "Allowed and restricted patterns for external project subdomains"
  type = object({
    allowed     = list(string)
    restricted  = list(string)
  })
  default = {
    allowed = [
      "*.dev", "*.test", "*.staging", "*.lab", 
      "dev-*", "test-*", "staging-*", "lab-*",
      "api", "app", "dashboard", "admin", "portal",
      "crewai", "n8n", "grafana", "prometheus"
    ]
    restricted = [
      "@", "www", "mail", "email", "mx", "mx*", 
      "ns", "ns*", "dns", "dns*", "ftp", "sftp",
      "autoconfig", "autodiscover", "lyncdiscover",
      "sip", "sipfed*", "_*", "dmarc", "dkim*",
      "selector*", "spf", "txt", "caa"
    ]
  }
}

variable "validate_dns_conflicts" {
  description = "Enable validation to prevent DNS conflicts with external projects"
  type        = bool
  default     = false  # Disabled by default - only enable for external project validation
}