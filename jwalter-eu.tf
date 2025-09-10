# jwalter.eu Domain Configuration
# Personal European domain with GDPR-compliant settings

module "jwalter_eu" {
  source = "./modules/domain"

  # Domain Configuration
  cloudflare_account_id = var.cloudflare_account_id
  domain_name           = "jwalter.eu"
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

  # Personal website subdomains + Google Workspace DNS Records
  dns_records = {
    "blog" = {
      name    = "blog"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    "cv" = {
      name    = "cv"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    "portfolio" = {
      name    = "portfolio"
      content = "31.43.160.6"
      type    = "A"
      ttl     = var.default_ttl
      proxied = true
    }
    # Google Workspace records already present
    "google_verification_cname" = {
      name    = "w6rdy3kudnli"
      content = "gv-5iv7mnlvddippf.dv.googlehosted.com."
      type    = "CNAME"
      ttl     = 300
    }
  }

  # TXT Records for verification, SPF, and DMARC
  txt_records = {
    "spf" = {
      name    = "@"
      content = "v=spf1 include:_spf.google.com include:spf.protection.outlook.com ~all"
      ttl     = var.default_ttl
    }
    "dmarc" = {
      name    = "_dmarc"
      content = "v=DMARC1; p=quarantine; sp=quarantine; pct=100; rua=mailto:dmarc@eirian.io; ruf=mailto:dmarc-forensic@eirian.io; fo=1"
      ttl     = var.default_ttl
    }
    "google_site_verification" = {
      name    = "@"
      content = "google-site-verification=uhkOPnBdxo-Koy6saXZUAgziS1G3lzP38CU-x3XfxtU"
      ttl     = 300
    }
    "atlassian_domain_verification" = {
      name    = "@"
      content = "atlassian-domain-verification=9KYj7bFkdqZCFKi4rDYnWzeAyyKqWvk8M6EmkrTa7ZbWCNHDsKBg7VphS2o9HIQL"
      ttl     = var.default_ttl
    }
  }

  # SRV Records - removed Office 365 specific records
  srv_records = {}

  # CloudFlare Settings - GDPR-compliant configuration
  security_level          = var.default_security_level
  enable_security_headers = var.enable_security_headers
  brotli_compression      = var.enable_performance_optimizations
  early_hints             = var.enable_performance_optimizations
  http3                   = var.enable_performance_optimizations
  zero_rtt                = var.enable_performance_optimizations

  # Privacy-focused settings for EU domain
  privacy_pass      = true
  email_obfuscation = true
  ip_geolocation    = false # Reduced tracking for EU compliance
  cache_level       = "aggressive"
  browser_cache_ttl = 14400
}