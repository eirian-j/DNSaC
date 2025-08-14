#!/bin/bash
# State migration script to move from individual resources to modular structure
# This preserves existing eirian.io resources without recreating them

echo "Starting Terraform state migration for eirian.io domain..."

# Move zone resource
echo "Migrating zone resource..."
terraform state mv cloudflare_zone.eirian_io module.eirian_io.cloudflare_zone.domain

# Move zone settings
echo "Migrating zone settings..."
terraform state mv cloudflare_zone_settings_override.eirian_io_settings module.eirian_io.cloudflare_zone_settings_override.domain_settings

# Move DNSSEC
echo "Migrating DNSSEC..."
terraform state mv cloudflare_zone_dnssec.eirian_io module.eirian_io.cloudflare_zone_dnssec.domain

# Move root A records (note: module uses "root_a" not "root_a_records")
echo "Migrating A records..."
terraform state mv cloudflare_record.root_a_1 'module.eirian_io.cloudflare_record.root_a[0]'
terraform state mv cloudflare_record.root_a_2 'module.eirian_io.cloudflare_record.root_a[1]'

# Move www CNAME (module uses conditional resource)
echo "Migrating www CNAME..."
terraform state mv cloudflare_record.www_cname 'module.eirian_io.cloudflare_record.www_cname[0]'

# Move MX record
echo "Migrating MX records..."
terraform state mv cloudflare_record.root_mx 'module.eirian_io.cloudflare_record.mx["root_mx"]'

# Move DNS records (CNAME records) - module uses "custom" not "dns_records"
echo "Migrating CNAME records..."
terraform state mv cloudflare_record.autodiscover_cname 'module.eirian_io.cloudflare_record.custom["autodiscover"]'
terraform state mv cloudflare_record.lyncdiscover_cname 'module.eirian_io.cloudflare_record.custom["lyncdiscover"]'
terraform state mv cloudflare_record.sip_cname 'module.eirian_io.cloudflare_record.custom["sip"]'
terraform state mv cloudflare_record.selector1_dkim_cname 'module.eirian_io.cloudflare_record.custom["selector1_dkim"]'
terraform state mv cloudflare_record.selector2_dkim_cname 'module.eirian_io.cloudflare_record.custom["selector2_dkim"]'

# Move TXT records - module uses "txt" not "txt_records"
echo "Migrating TXT records..."
terraform state mv cloudflare_record.ms_verification_txt 'module.eirian_io.cloudflare_record.txt["ms_verification"]'
terraform state mv cloudflare_record.root_spf_txt 'module.eirian_io.cloudflare_record.txt["spf"]'
terraform state mv 'cloudflare_record.dmarc[0]' 'module.eirian_io.cloudflare_record.txt["dmarc"]'

# Move SRV records - module uses "srv" not "srv_records"
echo "Migrating SRV records..."
terraform state mv cloudflare_record.sip_tls_srv 'module.eirian_io.cloudflare_record.srv["sip_tls"]'
terraform state mv cloudflare_record.sipfed_tcp_srv 'module.eirian_io.cloudflare_record.srv["sipfed_tcp"]'

echo "State migration completed!"
echo "Now running terraform plan to verify no changes needed for eirian.io..."