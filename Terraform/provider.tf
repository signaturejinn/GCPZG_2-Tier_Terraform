terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }
}

provider "google" {
  project = "terraform-366604"
  region  = "asia-northeast3"
  zone    = "asia-northeast3-a"
}