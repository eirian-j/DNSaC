# Example: Using the project-dns module with enforced naming conventions
# Structure: 
# - A record: service.project.env.domain.tld → IP
# - AAAA record: service.project.env.domain.tld → IPv6
# - CNAME: service-project-env.domain.tld → A/AAAA record

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  # Projects should use the limited API token
  api_token = var.project_api_token
}

# Get DNS configuration from the main DNSaC setup
data "terraform_remote_state" "dns" {
  backend = "local"
  config = {
    path = "../../terraform.tfstate"
  }
}

# Example for the "monika" project
module "monika_dns" {
  source = "../../modules/project-dns"

  zone_id = data.terraform_remote_state.dns.outputs.eirian_io_zone_id
  domain  = "eirian.io"
  project = "monika"  # Must be one of: monika, jarvis, hal

  services = {
    # API service deployed across multiple environments
    api = {
      environments = {
        dev = {
          a_records = [
            {
              ip_address = "10.0.1.10"
              ttl        = 300
              comment    = "Development API server"
            }
          ]
          # Creates: api-monika-dev.eirian.io → api.monika.dev.eirian.io
        }
        
        staging = {
          a_records = [
            {
              ip_address = "10.0.2.10"
              ttl        = 300
              comment    = "Staging API server"
            }
          ]
          aaaa_records = [
            {
              ipv6_address = "2001:db8:1::10"
              ttl          = 300
              comment      = "Staging API server IPv6"
            }
          ]
          # Creates: api-monika-staging.eirian.io → api.monika.staging.eirian.io
        }
        
        prod = {
          a_records = [
            {
              ip_address = "203.0.113.10"
              ttl        = 600
              comment    = "Production API server"
            },
            {
              ip_address = "203.0.113.11"
              ttl        = 600
              comment    = "Production API server 2"
            }
          ]
          aaaa_records = [
            {
              ipv6_address = "2001:db8:2::10"
              ttl          = 600
              comment      = "Production API IPv6"
            }
          ]
          # Creates: api-monika-prod.eirian.io → api.monika.prod.eirian.io
        }
      }
    }

    # Web application
    web = {
      environments = {
        dev = {
          a_records = [
            {
              ip_address = "10.0.1.20"
              ttl        = 300
            }
          ]
        }
        
        staging = {
          a_records = [
            {
              ip_address = "10.0.2.20"
              ttl        = 300
            }
          ]
        }
        
        prod = {
          a_records = [
            {
              ip_address = "203.0.113.20"
              ttl        = 600
            }
          ]
          aaaa_records = [
            {
              ipv6_address = "2001:db8:2::20"
              ttl          = 600
            }
          ]
        }
      }
    }

    # Database endpoints
    db = {
      environments = {
        lab = {
          a_records = [
            {
              ip_address = "10.0.0.30"
              ttl        = 120
              comment    = "Lab database"
            }
          ]
        }
        
        dev = {
          a_records = [
            {
              ip_address = "10.0.1.30"
              ttl        = 120
            }
          ]
        }
        
        staging = {
          a_records = [
            {
              ip_address = "10.0.2.30"
              ttl        = 120
            }
          ]
        }
      }
    }
  }
}

# Example for the "jarvis" project with minimal configuration
module "jarvis_dns" {
  source = "../../modules/project-dns"

  zone_id = data.terraform_remote_state.dns.outputs.eirian_io_zone_id
  domain  = "eirian.io"
  project = "jarvis"

  services = {
    dashboard = {
      environments = {
        dev = {
          a_records = [
            {
              ip_address = "10.0.1.40"
            }
          ]
        }
        
        prod = {
          a_records = [
            {
              ip_address = "203.0.113.40"
              ttl        = 3600
              comment    = "Jarvis dashboard production"
            }
          ]
          aaaa_records = [
            {
              ipv6_address = "2001:db8:3::40"
              ttl          = 3600
            }
          ]
        }
      }
    }
  }
}

# Example for the "hal" project with CNAME customization
module "hal_dns" {
  source = "../../modules/project-dns"

  zone_id = data.terraform_remote_state.dns.outputs.eirian_io_zone_id
  domain  = "eirian.io"
  project = "hal"

  services = {
    monitor = {
      environments = {
        prod = {
          a_records = [
            {
              ip_address = "203.0.113.50"
              ttl        = 1800
            }
          ]
          # Custom CNAME target (not following the default pattern)
          cname_target = "monitor.hal.prod.eirian.io"
          cname_ttl    = 1800
        }
      }
    }
  }
}

# Outputs
output "monika_records" {
  description = "DNS records created for Monika project"
  value = {
    a_records      = module.monika_dns.a_records
    aaaa_records   = module.monika_dns.aaaa_records
    cname_records  = module.monika_dns.cname_records
    by_environment = module.monika_dns.services_by_environment
    count          = module.monika_dns.record_count
  }
}

output "jarvis_records" {
  description = "DNS records created for Jarvis project"
  value = {
    a_records      = module.jarvis_dns.a_records
    aaaa_records   = module.jarvis_dns.aaaa_records
    cname_records  = module.jarvis_dns.cname_records
    by_environment = module.jarvis_dns.services_by_environment
    count          = module.jarvis_dns.record_count
  }
}

output "hal_records" {
  description = "DNS records created for HAL project"
  value = {
    a_records      = module.hal_dns.a_records
    aaaa_records   = module.hal_dns.aaaa_records
    cname_records  = module.hal_dns.cname_records
    by_environment = module.hal_dns.services_by_environment
    count          = module.hal_dns.record_count
  }
}