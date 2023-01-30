resource "google_sql_database_instance" "petclinic" {
  name                = "petclinic"
  database_version    = "MYSQL_5_7"
  root_password       = "petclinic"
  deletion_protection = false

  settings {
    tier              = "db-custom-2-3840"
    availability_type = "ZONAL"
    disk_size         = 10
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.default.id
    }
  }
  depends_on = [google_service_networking_connection.default]
}


resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}


resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database" "petclinic" {
  instance = google_sql_database_instance.petclinic.name
  name     = "petclinic"
}

resource "google_sql_user" "petclinic" {
  instance = google_sql_database_instance.petclinic.name
  name     = "petclinic"
  password = "petclinic"
}

// mysql -h 10.120.0.3 -u petclinic -p