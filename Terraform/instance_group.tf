resource "google_compute_snapshot" "default" {
  name        = "web-snapshot"
  zone        = "asia-northeast3-a"
  source_disk = google_compute_instance.default.name

  depends_on = [
    time_sleep.wait_12_minutes
  ]
}


resource "google_compute_image" "default" {
  name            = "web-image"
  source_snapshot = google_compute_snapshot.default.name

  depends_on = [
    google_compute_snapshot.default
  ]
}

resource "google_compute_instance_template" "default" {
  name                    = "web-template"
  machine_type            = "e2-micro"
  tags                    = ["web"]
  metadata_startup_script = "nohup java -jar ~/petclinic/target/*.jar --spring.profiles.active=mysql &"

  disk {
    source_image = google_compute_image.default.id
  }

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
  }

  depends_on = [google_compute_image.default]
}

resource "google_compute_region_instance_group_manager" "default" {
  name                      = "web-mig"
  base_instance_name        = "web-mig"
  distribution_policy_zones = ["asia-northeast3-a", "asia-northeast3-b"]

  version {
    instance_template = google_compute_instance_template.default.id
  }

  named_port {
    name = "tomcat"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.id
    initial_delay_sec = 300
  }

  depends_on = [google_compute_health_check.default, google_compute_instance_template.default]
}

resource "google_compute_health_check" "default" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "8080"
  }
}


resource "google_compute_region_autoscaler" "default" {
  name   = "web-mig-autoscaler"
  target = google_compute_region_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 6
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
  depends_on = [google_compute_region_instance_group_manager.default]
}