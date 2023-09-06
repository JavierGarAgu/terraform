terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("keys.json")

  project = "your-proyect-id"
  region  = "us-central1"
  zone    = "us-central1-c"
}

