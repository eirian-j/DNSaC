provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# CloudFlare Zone resource - Terraform manages the zone
resource "cloudflare_zone" "eirian_io" {
  account_id = var.cloudflare_account_id
  zone       = var.domain_name
  plan       = "free"
  type       = "full"
}

# Local for easier reference
locals {
  zone_id = cloudflare_zone.eirian_io.id
}

# Root A Records (specific IP addresses for eirian.io)
resource "cloudflare_record" "root_a_1" {
  zone_id = local.zone_id
  name    = "@"
  content = "31.43.160.6"
  type    = "A"
  ttl     = 1
  comment = "Root A record 1 managed by DNSaC"
}

resource "cloudflare_record" "root_a_2" {
  zone_id = local.zone_id
  name    = "@"
  content = "31.43.161.6"
  type    = "A"
  ttl     = 1
  comment = "Root A record 2 managed by DNSaC"
}

# WWW CNAME (Framer)
resource "cloudflare_record" "www_cname" {
  zone_id = local.zone_id
  name    = "www"
  content = "sites.framer.app."
  type    = "CNAME"
  ttl     = 1
  comment = "WWW CNAME managed by DNSaC"
}

# MX Record for Office 365/Outlook
resource "cloudflare_record" "root_mx" {
  zone_id  = local.zone_id
  name     = "@"
  content  = "eirian-io.mail.protection.outlook.com."
  type     = "MX"
  priority = 0
  ttl      = 1
  comment  = "MX record for Office 365 managed by DNSaC"
}

# Office 365/Outlook CNAME Records
resource "cloudflare_record" "autodiscover_cname" {
  zone_id = local.zone_id
  name    = "autodiscover"
  content = "autodiscover.outlook.com."
  type    = "CNAME"
  ttl     = 1
  comment = "Autodiscover for Office 365 managed by DNSaC"
}

resource "cloudflare_record" "lyncdiscover_cname" {
  zone_id = local.zone_id
  name    = "lyncdiscover"
  content = "webdir.online.lync.com."
  type    = "CNAME"
  ttl     = 1
  comment = "Lync discover for Teams managed by DNSaC"
}

resource "cloudflare_record" "sip_cname" {
  zone_id = local.zone_id
  name    = "sip"
  content = "sipdir.online.lync.com."
  type    = "CNAME"
  ttl     = 1
  comment = "SIP for Teams managed by DNSaC"
}

# DKIM CNAME Records
resource "cloudflare_record" "selector1_dkim_cname" {
  zone_id = local.zone_id
  name    = "selector1._domainkey"
  content = "selector1-eirian-io._domainkey.jewalter.onmicrosoft.com."
  type    = "CNAME"
  ttl     = 1
  comment = "DKIM selector 1 for Office 365 managed by DNSaC"
}

resource "cloudflare_record" "selector2_dkim_cname" {
  zone_id = local.zone_id
  name    = "selector2._domainkey"
  content = "selector2-eirian-io._domainkey.jewalter.onmicrosoft.com."
  type    = "CNAME"
  ttl     = 1
  comment = "DKIM selector 2 for Office 365 managed by DNSaC"
}

# SRV Records for Teams/Skype services
resource "cloudflare_record" "sip_tls_srv" {
  zone_id = local.zone_id
  name    = "_sip._tls"
  type    = "SRV"
  ttl     = 1800
  
  data {
    priority = 100
    weight   = 1
    port     = 443
    target   = "sipdir.online.lync.com."
  }
  
  comment = "SIP TLS SRV for Teams managed by DNSaC"
}

resource "cloudflare_record" "sipfed_tcp_srv" {
  zone_id = local.zone_id
  name    = "_sipfederationtls._tcp"
  type    = "SRV"
  ttl     = 1800
  
  data {
    priority = 100
    weight   = 1
    port     = 5061
    target   = "sipfed.online.lync.com."
  }
  
  comment = "SIP Federation SRV for Teams managed by DNSaC"
}

# TXT Records for verification and SPF
resource "cloudflare_record" "ms_verification_txt" {
  zone_id = local.zone_id
  name    = "@"
  content = "MS=ms55632057"
  type    = "TXT"
  ttl     = 1
  comment = "Microsoft verification record managed by DNSaC"
}

resource "cloudflare_record" "root_spf_txt" {
  zone_id = local.zone_id
  name    = "@"
  content = "v=spf1 include:spf.protection.outlook.com -all"
  type    = "TXT"
  ttl     = 1
  comment = "SPF record for Office 365 managed by DNSaC"
}

# DMARC record (optional, controlled by variable)
resource "cloudflare_record" "dmarc" {
  count   = var.dmarc_record != "" ? 1 : 0
  zone_id = local.zone_id
  name    = "_dmarc"
  content = var.dmarc_record
  type    = "TXT"
  ttl     = var.default_ttl
  comment = "DMARC record managed by DNSaC"
}