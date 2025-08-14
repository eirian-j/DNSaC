variable "cloudflare_api_token" {
  description = "CloudFlare API token with zone read and DNS edit permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "CloudFlare account ID (required for zone management)"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The domain name to manage"
  type        = string
  default     = "eirian.io"
}

variable "default_ttl" {
  description = "Default TTL for DNS records (used for optional records)"
  type        = number
  default     = 300
}

variable "dmarc_record" {
  description = "DMARC record value (optional)"
  type        = string
  default     = ""
}

# CloudFlare Settings Variables
variable "ssl_mode" {
  description = "SSL mode for the zone"
  type        = string
  default     = "flexible"
  
  validation {
    condition     = contains(["off", "flexible", "full", "strict"], var.ssl_mode)
    error_message = "SSL mode must be one of: off, flexible, full, strict."
  }
}

# Project-specific configurations
variable "project_records" {
  description = "Map of project names to their DNS record configurations"
  type = map(object({
    subdomain = string
    type      = string
    value     = string
    ttl       = optional(number, 300)
    priority  = optional(number)
    comment   = optional(string)
  }))
  default = {}
}

variable "allowed_subdomains" {
  description = "List of subdomain patterns that projects are allowed to create"
  type        = list(string)
  default     = ["*.dev", "*.staging", "*.test", "api", "app"]
}

variable "allowed_project_ips" {
  description = "List of IP addresses/ranges allowed to use the project API token"
  type        = list(string)
  default     = ["192.168.1.0/24", "10.0.0.0/8"]
}

# Firewall and Security Variables
variable "enable_geo_blocking" {
  description = "Enable geographic blocking for suspicious countries"
  type        = bool
  default     = false
}

variable "api_rate_limit_threshold" {
  description = "Rate limit threshold for API endpoints (requests per period)"
  type        = number
  default     = 50
}

variable "api_rate_limit_period" {
  description = "Rate limit period for API endpoints (seconds)"
  type        = number
  default     = 60
}

variable "api_rate_limit_timeout" {
  description = "Rate limit timeout for API endpoints (seconds)"
  type        = number
  default     = 600
}

variable "enable_general_rate_limit" {
  description = "Enable general rate limiting for the entire domain"
  type        = bool
  default     = false
}

variable "general_rate_limit_threshold" {
  description = "General rate limit threshold (requests per period)"
  type        = number
  default     = 100
}

variable "general_rate_limit_period" {
  description = "General rate limit period (seconds)"
  type        = number
  default     = 60
}

variable "general_rate_limit_timeout" {
  description = "General rate limit timeout (seconds)"
  type        = number
  default     = 300
}