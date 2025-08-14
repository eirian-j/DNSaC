# myrisk.now Domain Configuration  
# Short, memorable domain for rapid deployment and testing

module "myrisk_now" {
  source = "./modules/domain"
  
  # Domain Configuration
  cloudflare_account_id = var.cloudflare_account_id
  domain_name          = "myrisk.now"
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
  default_ttl         = 300   # Shorter TTL for rapid deployment
  
  # Office 365 MX Records
  mx_records = {
    "root_mx" = {
      name     = "@"
      content  = "myrisk-now.mail.protection.outlook.com."
      priority = 0
      ttl      = 300
    }
  }

  # Development and Testing Subdomains + Office 365 DNS Records
  dns_records = {
    "dev" = {
      name    = "dev"
      content = "31.43.160.6"
      type    = "A"
      ttl     = 300
      proxied = true
    }
    "staging" = {
      name    = "staging"
      content = "31.43.161.6"
      type    = "A"
      ttl     = 300
      proxied = true
    }
    "test" = {
      name    = "test"
      content = "31.43.160.6"
      type    = "A"
      ttl     = 300
      proxied = true
    }
    "autodiscover" = {
      name    = "autodiscover"
      content = "autodiscover.outlook.com."
      type    = "CNAME"
      ttl     = 300
    }
    "lyncdiscover" = {
      name    = "lyncdiscover"
      content = "webdir.online.lync.com."
      type    = "CNAME"
      ttl     = 300
    }
    "sip" = {
      name    = "sip"
      content = "sipdir.online.lync.com."
      type    = "CNAME"
      ttl     = 300
    }
    "selector1_dkim" = {
      name    = "selector1._domainkey"
      content = "selector1-myrisk-now._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = 300
    }
    "selector2_dkim" = {
      name    = "selector2._domainkey"
      content = "selector2-myrisk-now._domainkey.jewalter.onmicrosoft.com."
      type    = "CNAME"
      ttl     = 300
    }
  }
  
  # TXT Records for verification, SPF, and DMARC
  txt_records = {
    "spf" = {
      name    = "@"
      content = "v=spf1 include:spf.protection.outlook.com -all"
      ttl     = 300
    }
    "dmarc" = {
      name    = "_dmarc"
      content = "v=DMARC1; p=quarantine; rua=mailto:dmarc@eirian.io"
      ttl     = 300
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
  
  # CloudFlare Settings - Optimized for rapid deployment
  security_level              = "medium"
  enable_security_headers     = var.enable_security_headers
  brotli_compression         = var.enable_performance_optimizations
  early_hints               = var.enable_performance_optimizations
  http3                     = var.enable_performance_optimizations
  zero_rtt                  = var.enable_performance_optimizations
  
  # Development-friendly settings
  cache_level                = "basic"      # Less aggressive caching for dev
  browser_cache_ttl          = 3600        # 1 hour cache for rapid iteration
  development_mode           = false       # Can be enabled manually when needed
}