output "record_id" {
  description = "ID of the created DNS record"
  value       = local.subdomain_valid ? cloudflare_record.project_record[0].id : null
}

output "record_fqdn" {
  description = "Fully qualified domain name of the created record"
  value       = local.subdomain_valid ? cloudflare_record.project_record[0].hostname : null
}

output "record_value" {
  description = "Value of the created DNS record"
  value       = local.subdomain_valid ? cloudflare_record.project_record[0].value : null
}