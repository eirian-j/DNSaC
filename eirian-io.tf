# eirian.io Domain Configuration
# Primary domain with Office 365 integration and CloudFlare proxy

module "eirian_io" {
  source = "./modules/domain"

  # Domain Configuration
  cloudflare_account_id = var.cloudflare_account_id
  domain_name           = "eirian.io"
  plan                  = var.default_plan

  # DNS Records
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

  # Office 365 DNS Records
  dns_records = {
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
      content = "selector1-eirian-io._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "selector2_dkim" = {
      name    = "selector2._domainkey"
      content = "selector2-eirian-io._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "google_recovery_cname" = {
      name    = "62295987"
      content = "google.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "google_verification_cname" = {
      name    = "yd6ro7kigzmb"
      content = "gv-ghtbyeeujqhsl2.dv.googlehosted.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
  }

  # TXT Records for verification, SPF, and DMARC
  txt_records = {
    "ms_verification" = {
      name    = "@"
      content = "MS=ms55632057"
      ttl     = var.default_ttl
    }
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
    "google_recovery_domain" = {
      name    = "@"
      content = "google-gws-recovery-domain-verification=62295987"
      ttl     = var.default_ttl
    }
    "google_site_verification" = {
      name    = "@"
      content = "google-site-verification=QtBEXtpr8N35Z4aJeryUiA3EupXPHJZ1G7Z0hIpRwn8"
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

  # CloudFlare Settings
  security_level          = var.default_security_level
  enable_security_headers = var.enable_security_headers
  brotli_compression      = var.enable_performance_optimizations
  early_hints             = var.enable_performance_optimizations
  http3                   = var.enable_performance_optimizations
  zero_rtt                = var.enable_performance_optimizations
}