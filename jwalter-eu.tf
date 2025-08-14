# jwalter.eu Domain Configuration
# Personal European domain with GDPR-compliant settings

module "jwalter_eu" {
  source = "./modules/domain"
  
  # Domain Configuration
  cloudflare_account_id = var.cloudflare_account_id
  domain_name          = "jwalter.eu"
  plan                = var.default_plan
  
  # DNS Records - Same infrastructure as eirian.io
  root_a_records = [
    "31.43.160.6",
    "31.43.161.6"
  ]
  
  www_cname_target = "sites.framer.app."
  
  # SSL and Proxy Settings
  ssl_mode            = var.default_ssl_mode
  proxy_root_records  = var.default_proxy_enabled
  proxy_www_record    = false  # Keep www pointing to Framer directly
  default_ttl         = var.default_ttl
  
  # Office 365 MX Records
  mx_records = {
    "root_mx" = {
      name     = "@"
      content  = "jwalter-eu.mail.protection.outlook.com."
      priority = 0
      ttl      = var.default_ttl
    }
  }

  # Personal website subdomains + Office 365 DNS Records
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
      content = "selector1-jwalter-eu._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
    "selector2_dkim" = {
      name    = "selector2._domainkey"
      content = "selector2-jwalter-eu._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = var.default_ttl
    }
  }
  
  # TXT Records for verification, SPF, and DMARC
  txt_records = {
    "spf" = {
      name    = "@"
      content = "v=spf1 include:spf.protection.outlook.com -all"
      ttl     = var.default_ttl
    }
    "dmarc" = {
      name    = "_dmarc"
      content = "v=DMARC1; p=reject; sp=reject; pct=100; rua=mailto:dmarc@eirian.io; ruf=mailto:dmarc-forensic@eirian.io; fo=1"
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
  
  # CloudFlare Settings - GDPR-compliant configuration
  security_level              = var.default_security_level
  enable_security_headers     = var.enable_security_headers
  brotli_compression         = var.enable_performance_optimizations
  early_hints               = var.enable_performance_optimizations
  http3                     = var.enable_performance_optimizations
  zero_rtt                  = var.enable_performance_optimizations
  
  # Privacy-focused settings for EU domain
  privacy_pass               = true
  email_obfuscation          = true
  ip_geolocation            = false    # Reduced tracking for EU compliance
  cache_level               = "aggressive"
  browser_cache_ttl         = 14400
}