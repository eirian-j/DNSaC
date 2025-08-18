# Module for projects to manage their DNS records with strict naming conventions
# Enforces: 
# - A record: service.project.env.domain.tld → IP
# - CNAME record: service-project-env.domain.tld → A record
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

locals {
  # Flatten services and environments into individual DNS records
  a_records = flatten([
    for service_name, service in var.services : [
      for env_name, env in service.environments : [
        for idx, a_record in coalesce(env.a_records, []) : {
          key     = "${service_name}-${var.project}-${env_name}-a-${idx}"
          service = service_name
          env     = env_name
          # A record format: service.project.env.domain.tld
          name    = "${service_name}.${var.project}.${env_name}"
          type    = "A"
          value   = a_record.ip_address
          ttl     = a_record.ttl
          comment = coalesce(a_record.comment, "${var.project}/${service_name} - ${env_name} environment")
        }
      ]
    ]
  ])

  # Flatten AAAA records for IPv6
  aaaa_records = flatten([
    for service_name, service in var.services : [
      for env_name, env in service.environments : [
        for idx, aaaa_record in coalesce(env.aaaa_records, []) : {
          key     = "${service_name}-${var.project}-${env_name}-aaaa-${idx}"
          service = service_name
          env     = env_name
          # AAAA record format: service.project.env.domain.tld
          name    = "${service_name}.${var.project}.${env_name}"
          type    = "AAAA"
          value   = aaaa_record.ipv6_address
          ttl     = aaaa_record.ttl
          comment = coalesce(aaaa_record.comment, "${var.project}/${service_name} - ${env_name} IPv6")
        }
      ]
    ]
  ])

  # Create CNAME records that point to the A/AAAA records
  cname_records = flatten([
    for service_name, service in var.services : [
      for env_name, env in service.environments : {
        key     = "${service_name}-${var.project}-${env_name}-cname"
        service = service_name
        env     = env_name
        # CNAME format: service-project-env.domain.tld
        name = "${service_name}-${var.project}-${env_name}"
        type = "CNAME"
        # Points to the A/AAAA record
        value = coalesce(
          env.cname_target,
          "${service_name}.${var.project}.${env_name}.${var.domain}"
        )
        ttl     = env.cname_ttl
        comment = coalesce(env.cname_comment, "${var.project}/${service_name} - ${env_name} CNAME")
      } if length(coalesce(env.a_records, [])) > 0 || length(coalesce(env.aaaa_records, [])) > 0 || env.cname_target != null
    ]
  ])

  # Combine all records into a single map
  all_records = merge(
    { for record in local.a_records : record.key => record },
    { for record in local.aaaa_records : record.key => record },
    { for record in local.cname_records : record.key => record }
  )
}

# Create A records for services
resource "cloudflare_record" "a_records" {
  for_each = { for record in local.a_records : record.key => record }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = each.value.ttl
  comment = each.value.comment

  lifecycle {
    prevent_destroy = false
  }
}

# Create AAAA records for IPv6
resource "cloudflare_record" "aaaa_records" {
  for_each = { for record in local.aaaa_records : record.key => record }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = each.value.ttl
  comment = each.value.comment

  lifecycle {
    prevent_destroy = false
  }
}

# Create CNAME records pointing to A/AAAA records
resource "cloudflare_record" "cname_records" {
  for_each = { for record in local.cname_records : record.key => record }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  value   = each.value.value
  ttl     = each.value.ttl
  comment = each.value.comment

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [cloudflare_record.a_records, cloudflare_record.aaaa_records]
}