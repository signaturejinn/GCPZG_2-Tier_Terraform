resource "google_compute_global_address" "proxy" {
  name = "proxy-static-ip"
}

resource "google_compute_health_check" "backend-http" {
  name = "http-hc"

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

resource "google_compute_backend_service" "web" {
  name                  = "backend-service"
  protocol              = "HTTP"
  port_name             = "tomcat" # MIG PORT NAME
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = false
  health_checks         = [google_compute_health_check.backend-http.id]
  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "default" {
  name            = "default-url-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_url_map" "https-redirect" {
  name = "https-redirect-map"

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "petclinic-cert"

  managed {
    domains = [google_dns_record_set.a.name]
  }
}


resource "google_compute_target_http_proxy" "default" {
  name    = "http-proxy"
  url_map = google_compute_url_map.https-redirect.id
}

resource "google_compute_target_https_proxy" "default" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_global_forwarding_rule" "http" {
  name       = "http-forwarding-rule"
  port_range = "80"
  target     = google_compute_target_http_proxy.default.id
  ip_address = google_compute_global_address.proxy.id
}

resource "google_compute_global_forwarding_rule" "https" {
  name       = "https-forwarding-rule"
  port_range = "443"
  target     = google_compute_target_https_proxy.default.id
  ip_address = google_compute_global_address.proxy.id
}

