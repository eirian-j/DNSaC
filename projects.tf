# Project-specific DNS records with validation
locals {
  # Validate that project subdomains match allowed patterns
  validated_projects = {
    for project_name, config in var.project_records : project_name => config
    if can(regex(join("|", [for pattern in var.allowed_subdomains : replace(pattern, "*", ".*")]), config.subdomain))
  }
}

# Project DNS records
resource "cloudflare_record" "project_records" {
  for_each = local.validated_projects

  zone_id  = cloudflare_zone.eirian_io.id
  name     = each.value.subdomain
  content  = each.value.value
  type     = each.value.type
  ttl      = each.value.ttl
  priority = each.value.priority
  comment  = "Project: ${each.key} - ${coalesce(each.value.comment, "Managed by DNSaC")}"

  lifecycle {
    # Prevent accidental deletion of project records
    prevent_destroy = false
    # Projects can only update their own records
    ignore_changes = []
  }
}

# CloudFlare API token for projects (limited permissions)
# NOTE: API token creation requires higher API token permissions
# Projects will need to manually create limited-scope tokens
# Commented out for API permission compatibility

# resource "cloudflare_api_token" "project_token" {
#   name = "DNSaC-Projects-Token"
# 
#   policy {
#     permission_groups = [
#       "c8fed203ed3043cba015a93ad1616681", # Zone:Read
#       "4755a26eedb94da69e1066d98aa820be", # DNS:Edit
#     ]
#     resources = {
#       "com.cloudflare.api.account.zone.*" = "*"
#     }
#   }
# 
#   condition {
#     request_ip {
#       in     = var.allowed_project_ips
#       not_in = []
#     }
#   }
# 
#   not_before = timestamp()
#   expires_on = timeadd(timestamp(), "8760h") # 1 year
# }

