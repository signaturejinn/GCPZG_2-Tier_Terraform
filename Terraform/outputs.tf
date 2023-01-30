output "DB_PRIVATE_IP" {
  description = ""
  value       = google_sql_database_instance.petclinic.private_ip_address
}

output "BASE_INSTANCE_PUBLIC_IP" {
  description = ""
  value       = "http://${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}:8080"
}

output "NAME_SERVERS" {
  description = ""
  value = google_dns_managed_zone.shop.name_servers
  # value       = join(", ", google_dns_managed_zone.shop.name_servers)

}

output "DNS" {
  description = ""
  value       = google_dns_record_set.a.name

}

output "PROXY_IP" {
  description = ""
  value       = google_compute_global_address.proxy.address

}