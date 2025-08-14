variable "zone_id" {
  description = "CloudFlare zone ID"
  type        = string
}

variable "project_name" {
  description = "Name of the project creating the DNS record"
  type        = string
}

variable "subdomain" {
  description = "Subdomain to create (e.g., 'api' or 'myapp.dev')"
  type        = string

  validation {
    condition     = length(var.subdomain) > 0 && length(var.subdomain) <= 63
    error_message = "Subdomain must be between 1 and 63 characters."
  }
}

variable "type" {
  description = "DNS record type"
  type        = string
  
  validation {
    condition     = contains(["A", "AAAA", "CNAME", "TXT", "MX", "SRV"], var.type)
    error_message = "Type must be one of: A, AAAA, CNAME, TXT, MX, SRV."
  }
}

variable "value" {
  description = "DNS record value"
  type        = string
}

variable "ttl" {
  description = "DNS record TTL"
  type        = number
  default     = 300

  validation {
    condition     = var.ttl >= 60 && var.ttl <= 86400
    error_message = "TTL must be between 60 and 86400 seconds."
  }
}

variable "priority" {
  description = "Priority for MX/SRV records"
  type        = number
  default     = null
}

variable "comment" {
  description = "Comment for the DNS record"
  type        = string
  default     = "Managed by project"
}

variable "allowed_subdomains" {
  description = "List of allowed subdomain patterns"
  type        = list(string)
}