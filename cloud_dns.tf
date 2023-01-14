resource "google_dns_managed_zone" "shop" {
  name        = "petclinic"
  dns_name    = "petclinic.shop."
  description = "Petclinic DNS Zone"
}

resource "google_dns_record_set" "a" {
  name         = "www.${google_dns_managed_zone.shop.dns_name}"
  managed_zone = google_dns_managed_zone.shop.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.proxy.address]

  depends_on = [
    google_compute_global_address.proxy
  ]

}


