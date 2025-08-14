# CloudFlare WAF Custom Rules (replaces deprecated firewall rules)
# NOTE: WAF Custom Rules require CloudFlare Pro plan or higher
# Commented out for free plan compatibility

# resource "cloudflare_ruleset" "zone_custom_firewall" {
#   zone_id     = local.zone_id
#   name        = "Custom Firewall Rules"
#   description = "Custom WAF rules for security protection"
#   kind        = "zone"
#   phase       = "http_request_firewall_custom"
# 
#   # Block known bad bots
#   rules {
#     action      = "challenge"
#     expression  = "(cf.client.bot) and not (cf.verified_bot)"
#     description = "Block known bad bots"
#     enabled     = true
#   }
# 
#   # Block common attack patterns
#   rules {
#     action      = "block"
#     expression  = "(http.request.uri.path contains \"wp-admin\") or (http.request.uri.path contains \"wp-login\") or (http.request.uri.path contains \".php\") or (http.request.uri.path contains \"admin\")"
#     description = "Block common attack patterns"
#     enabled     = true
#   }
# 
#   # Challenge suspicious countries (conditional)
#   dynamic "rules" {
#     for_each = var.enable_geo_blocking ? [1] : []
#     content {
#       action      = "challenge"
#       expression  = "(ip.geoip.country in {\"CN\" \"RU\" \"KP\" \"IR\"})"
#       description = "Challenge requests from suspicious countries"
#       enabled     = true
#     }
#   }
# }

# Rate Limiting Rules using modern cloudflare_ruleset approach
# NOTE: Advanced rate limiting requires CloudFlare Pro plan or higher
# Commented out for free plan compatibility

# resource "cloudflare_ruleset" "zone_rate_limiting" {
#   zone_id     = local.zone_id
#   name        = "Rate Limiting Rules"
#   description = "Rate limiting protection for API and general endpoints"
#   kind        = "zone"
#   phase       = "http_ratelimit"
# 
#   # API Rate Limiting
#   rules {
#     action = "block"
#     ratelimit {
#       characteristics = [
#         "cf.colo.id",
#         "ip.src"
#       ]
#       period              = var.api_rate_limit_period
#       requests_per_period = var.api_rate_limit_threshold
#       mitigation_timeout  = var.api_rate_limit_timeout
#     }
#     expression  = "(http.host eq \"api.${var.domain_name}\")"
#     description = "Rate limit API endpoints"
#     enabled     = true
#   }
# 
#   # General Rate Limiting (conditional)
#   dynamic "rules" {
#     for_each = var.enable_general_rate_limit ? [1] : []
#     content {
#       action = "log" # Using log instead of simulate for modern approach
#       ratelimit {
#         characteristics = [
#           "cf.colo.id",
#           "ip.src"
#         ]
#         period              = var.general_rate_limit_period
#         requests_per_period = var.general_rate_limit_threshold
#         mitigation_timeout  = var.general_rate_limit_timeout
#       }
#       expression  = "(http.host eq \"${var.domain_name}\")"
#       description = "General rate limiting for entire domain"
#       enabled     = true
#     }
#   }
# }