# DNSSEC configuration for eirian.io
# Import existing DNSSEC configuration to align with production

data "cloudflare_zone_dnssec" "eirian_io" {
  zone_id = cloudflare_zone.eirian_io.id
}

# Resource to manage DNSSEC (import existing state)
resource "cloudflare_zone_dnssec" "eirian_io" {
  zone_id = cloudflare_zone.eirian_io.id
}