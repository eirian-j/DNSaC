# Multi-Domain CloudFlare Notification Policies
# Comprehensive SSL certificate monitoring across all managed domains

# SSL Certificate Expiry Notification Policy (All Domains)
resource "cloudflare_notification_policy" "ssl_certificate_expiry" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Multi-Domain SSL Certificate Expiry Alert"
  description = "Alert when SSL certificates are expiring for any managed domain"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  email_integration {
    id = var.notification_email
  }
}

# Origin Certificate Events (All Domains)
resource "cloudflare_notification_policy" "origin_ssl_events" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Multi-Domain Origin SSL Certificate Events"
  description = "Monitor origin SSL certificate changes and validation issues across all domains"
  enabled     = true
  alert_type  = "custom_ssl_certificate_event_type"
  
  email_integration {
    id = var.notification_email
  }
}

# General SSL Validation Alerts (All Domains)
resource "cloudflare_notification_policy" "ssl_validation_errors" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Multi-Domain SSL Validation Alerts"
  description = "Alert on SSL validation failures in strict mode across all domains"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  email_integration {
    id = var.notification_email
  }
}

# Zone-specific notification policies for critical domains
resource "cloudflare_notification_policy" "eirian_io_critical" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Critical - eirian.io Events"
  description = "High-priority alerts for primary business domain"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  filters {
    zones = [module.eirian_io.zone_id]
  }
  
  email_integration {
    id = var.notification_email
  }
}

# Business domains notification policy
resource "cloudflare_notification_policy" "business_domains" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Business Domains SSL Events"
  description = "SSL events for business-critical domains (eirian.io, eirianconsulting.com)"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  filters {
    zones = [
      module.eirian_io.zone_id,
      module.eirianconsulting_com.zone_id
    ]
  }
  
  email_integration {
    id = var.notification_email
  }
}