# Create a bucket
# Upload function.zip
# Deploy function
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

resource "google_storage_bucket_object" "srccode" {
  name = "function"
  source = "function/function.zip"
  bucket = google_storage_bucket.func_cf.name
}