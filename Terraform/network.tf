resource "google_compute_network" "default" {
  name                    = "petclinic-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "petclinic-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.default.id
}


resource "google_compute_firewall" "allow-80-ig" {
  name      = "allow-80-ig"
  network   = google_compute_network.default.name
  direction = "INGRESS"
  priority  = 300

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}
  #   source_tags = [ "value" ]
  #   source_ranges =  ["35.191.0.0/16", "130.211.0.0/22"]

resource "google_compute_firewall" "allow-22-ig" {
  name      = "allow-22-ig"
  network   = google_compute_network.default.name
  direction = "INGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
}

  #   source_tags = [ "value" ]
  #   source_ranges = [ "35.235.240.0/20" ]

resource "google_compute_firewall" "allow-all-eg" {
  name      = "allow-all-eg"
  network   = google_compute_network.default.name
  direction = "EGRESS"
  priority  = 65535

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "deny-all-ig" {
  name      = "deny-all-ig"
  network   = google_compute_network.default.name
  direction = "INGRESS"
  priority  = 65535

  deny {
    protocol = "all"

  }
  source_ranges = ["0.0.0.0/0"]
}
