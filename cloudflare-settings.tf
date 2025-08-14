# CloudFlare Zone Settings and Security Configuration

# CloudFlare Settings for the zone
resource "cloudflare_zone_settings_override" "eirian_io_settings" {
  zone_id = local.zone_id

  settings {
    # Security
    security_level         = "medium"
    challenge_ttl         = 1800
    browser_check         = "on"
    
    # SSL/TLS
    ssl                   = var.ssl_mode
    always_use_https      = "on"
    min_tls_version       = "1.2"
    opportunistic_encryption = "on"
    opportunistic_onion   = "on"
    automatic_https_rewrites = "on"
    
    # Performance
    brotli = "on"
    # NOTE: Minify settings may not be available on free plan
    # Commented out if causing issues
    # minify {
    #   css  = "on"
    #   js   = "on"
    #   html = "on"
    # }
    
    # Caching
    browser_cache_ttl = 14400
    cache_level      = "aggressive"
    
    # Network
    websockets       = "on"
    ip_geolocation   = "on"
    ipv6            = "on"
    
    # Other
    development_mode = "off"
    rocket_loader   = "on"
    
    # Security Headers
    security_header {
      enabled            = true
      include_subdomains = true
      preload           = true
      max_age           = 31536000
    }
  }
}

# Page Rules (Free plan includes 3 page rules)
# NOTE: Free plan allows 3 page rules total. We already have 1 existing rule.
# Force HTTPS is already handled by zone settings (always_use_https = "on")
# Commented out to stay within free plan limits

# resource "cloudflare_page_rule" "force_https" {
#   zone_id  = local.zone_id
#   target   = "${var.domain_name}/*"
#   priority = 1
# 
#   actions {
#     always_use_https = true
#     ssl             = var.ssl_mode
#   }
# }

# Commented out due to free plan limit (3 page rules max)
# resource "cloudflare_page_rule" "api_bypass_cache" {
#   zone_id  = local.zone_id
#   target   = "api.${var.domain_name}/*"
#   priority = 2
#
#   actions {
#     cache_level = "bypass"
#   }
# }

# resource "cloudflare_page_rule" "www_redirect" {
#   zone_id  = local.zone_id
#   target   = "www.${var.domain_name}/*"
#   priority = 3
#
#   actions {
#     forwarding_url {
#       url         = "https://${var.domain_name}/$1"
#       status_code = 301
#     }
#   }
# }