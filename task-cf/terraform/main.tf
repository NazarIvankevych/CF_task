# Create a bucket
# Upload function.zip --> +
# Deploy function --> +
# create a trigger
# policy binding

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.44.1"
    }
  }
}

provider "google" {
  # Configuration options
  project = "task-cf-370710"
  region = "us-central1"
  zone = "us-central1-c"
}

resource "google_storage_bucket" "func_cf" {
  name = "func_cf_tf"
  location = "US"
}

resource "google_storage_bucket_object" "function_code_archive" {
  name = "function"
  source = "function.zip"
  bucket = google_storage_bucket.func_cf.name
}

resource "google_cloudfunctions_function" "func_cf_tf" {
  name = "func_cf_tf"
  source_archive_bucket = google_storage_bucket.func_cf.name
  source_archive_object = google_storage_bucket_object.function_code_archive.name
  available_memory_mb = 128
  entry_point         = "main"
  runtime             = "python38"
  trigger_http = true
  timeout               = 540
}