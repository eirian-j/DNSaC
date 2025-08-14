# DNSaC Global Variables
# Shared variables across all domains

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

# Notification Settings
variable "notification_email" {
  description = "Email address for CloudFlare notifications"
  type        = string
  default     = "cloudflare.alerts@eirian.io"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.notification_email))
    error_message = "Must be a valid email address."
  }
}

# Default Settings for All Domains
variable "default_ssl_mode" {
  description = "Default SSL mode for all domains"
  type        = string
  default     = "strict"
  
  validation {
    condition     = contains(["off", "flexible", "full", "strict"], var.default_ssl_mode)
    error_message = "SSL mode must be one of: off, flexible, full, strict."
  }
}

variable "default_proxy_enabled" {
  description = "Default proxy setting for root records"
  type        = bool
  default     = true
}

variable "default_ttl" {
  description = "Default TTL for DNS records across all domains"
  type        = number
  default     = 300
  
  validation {
    condition     = var.default_ttl >= 60 && var.default_ttl <= 86400
    error_message = "TTL must be between 60 and 86400 seconds."
  }
}

variable "default_plan" {
  description = "Default CloudFlare plan for domains"
  type        = string
  default     = "free"
  
  validation {
    condition     = contains(["free", "pro", "business", "enterprise"], var.default_plan)
    error_message = "Plan must be one of: free, pro, business, enterprise."
  }
}

# Security Settings
variable "default_security_level" {
  description = "Default security level for all domains"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["essentially_off", "low", "medium", "high", "under_attack"], var.default_security_level)
    error_message = "Security level must be one of: essentially_off, low, medium, high, under_attack."
  }
}

variable "enable_security_headers" {
  description = "Enable security headers by default"
  type        = bool
  default     = true
}

# Performance Settings
variable "enable_performance_optimizations" {
  description = "Enable performance optimizations (Brotli, HTTP/3, Early Hints)"
  type        = bool
  default     = true
}