# CloudFlare Notification Policies for SSL Certificate Monitoring
# Terraform-managed alerting for certificate expiry and SSL events

# SSL Certificate Expiry Notification Policy
resource "cloudflare_notification_policy" "ssl_certificate_expiry" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC SSL Certificate Expiry Alert"
  description = "Alert when SSL certificates are expiring for eirian.io"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  # Email notification
  email_integration {
    id = "cloudflare.alerts@eirian.io"
  }
}

# Origin Certificate Events (custom SSL certificate monitoring)
resource "cloudflare_notification_policy" "origin_ssl_events" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC Origin SSL Certificate Events"
  description = "Monitor origin SSL certificate changes and validation issues"
  enabled     = true
  alert_type  = "custom_ssl_certificate_event_type"
  
  # Email notification
  email_integration {
    id = "cloudflare.alerts@eirian.io"
  }
}

# SSL Validation Error Alerts for Strict Mode
# Note: Simplified without filters due to API limitations
resource "cloudflare_notification_policy" "ssl_validation_errors" {
  account_id  = var.cloudflare_account_id
  name        = "DNSaC SSL Validation Error Alerts"
  description = "Alert on SSL validation failures in strict mode"
  enabled     = true
  alert_type  = "universal_ssl_event_type"
  
  email_integration {
    id = "cloudflare.alerts@eirian.io"
  }
}