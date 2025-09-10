# walter.sg Domain Configuration
# Singapore personal domain with Asia-Pacific optimization

module "walter_sg" {
  source = "./modules/domain"

  # Domain Configuration
  cloudflare_account_id = var.cloudflare_account_id
  domain_name           = "walter.sg"
  plan                  = var.default_plan

  # DNS Records - Same infrastructure as eirian.io
  root_a_records = [
    "31.43.160.6",
    "31.43.161.6"
  ]

  www_cname_target = "sites.framer.app."

  # SSL and Proxy Settings
  ssl_mode           = var.default_ssl_mode
  proxy_root_records = var.default_proxy_enabled
  proxy_www_record   = false # Keep www pointing to Framer directly
  default_ttl        = var.default_ttl

  # Google Workspace MX Records
  mx_records = {
    "google_mx_1" = {
      name     = "@"
      content  = "aspmx.l.google.com."
      priority = 1
      ttl      = var.default_ttl
    }
    "google_mx_2" = {
      name     = "@"
      content  = "alt1.aspmx.l.google.com."
      priority = 5
      ttl      = var.default_ttl
    }
    "google_mx_3" = {
      name     = "@"
      content  = "alt2.aspmx.l.google.com."
      priority = 5
      ttl      = var.default_ttl
    }
    "google_mx_4" = {
      name     = "@"
      content  = "alt3.aspmx.l.google.com."
      priority = 10
      ttl      = var.default_ttl
    }
    "google_mx_5" = {
      name     = "@"
      content  = "alt4.aspmx.l.google.com."
      priority = 10
      ttl      = var.default_ttl
    }
  }

  # Personal and business subdomains for Singapore + Office 365 DNS Records
  dns_records = {
    "asia" = {
      name    = "asia"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    "sg" = {
      name    = "sg"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    "contact" = {
      name    = "contact"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    "autodiscover" = {
      name    = "autodiscover"
      content = "autodiscover.outlook.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "lyncdiscover" = {
      name    = "lyncdiscover"
      content = "webdir.online.lync.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "sip" = {
      name    = "sip"
      content = "sipdir.online.lync.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "selector1_dkim" = {
      name    = "selector1._domainkey"
      content = "selector1-walter-sg._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "selector2_dkim" = {
      name    = "selector2._domainkey"
      content = "selector2-walter-sg._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "google_verification_cname" = {
      name    = "j6vcrjzxejl6"
      content = "gv-ilbmfiqfvbe4mr.dv.googlehosted.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
  }

  # TXT Records for verification, SPF, and DMARC
  txt_records = {
    "spf" = {
      name    = "@"
      content = "v=spf1 include:_spf.google.com ~all"
      ttl     = var.default_ttl
    }
    "dmarc" = {
      name    = "_dmarc"
      content = "v=DMARC1; p=quarantine; sp=quarantine; pct=100; rua=mailto:dmarc@eirian.io; ruf=mailto:dmarc-forensic@eirian.io; fo=1"
      ttl     = var.default_ttl
    }
    "google_site_verification" = {
      name    = "@"
      content = "google-site-verification=p2C31F1L9KXzxVjSnGnTOABIMgSdssyoWgeEBeGbSr0"
      ttl     = var.default_ttl
    }
    "atlassian_domain_verification" = {
      name    = "@"
      content = "atlassian-domain-verification=9KYj7bFkdqZCFKi4rDYnWzeAyyKqWvk8M6EmkrTa7ZbWCNHDsKBg7VphS2o9HIQL"
      ttl     = var.default_ttl
    }
  }

  # SRV Records for Teams/Skype services
  srv_records = {
    "sip_tls" = {
      name     = "_sip._tls"
      priority = 100
      weight   = 1
      port     = 443
      target   = "sipdir.online.lync.com."
      ttl      = 1800
    }
    "sipfed_tcp" = {
      name     = "_sipfederationtls._tcp"
      priority = 100
      weight   = 1
      port     = 5061
      target   = "sipfed.online.lync.com."
      ttl      = 1800
    }
  }

  # CloudFlare Settings - Optimized for Asia-Pacific region
  security_level          = var.default_security_level
  enable_security_headers = var.enable_security_headers
  brotli_compression      = var.enable_performance_optimizations
  early_hints             = var.enable_performance_optimizations
  http3                   = var.enable_performance_optimizations
  zero_rtt                = var.enable_performance_optimizations

  # Singapore-specific optimizations
  cache_level              = "aggressive"
  browser_cache_ttl        = 14400
  ip_geolocation           = true # Useful for regional content
  opportunistic_encryption = true
}