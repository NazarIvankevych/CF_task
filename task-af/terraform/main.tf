terraform {
    backend "gcs" {
        prefix = "task-df"
        bucket = "big-data-bucket125478"
    }
}

provider "google" {
    # Configuration options
    project = var.project_id
    region = var.region
}

resource "google_storage_bucket" "bucket" {
    name     = var.bucket_id
    location = var.location
    force_destroy = true
}

resource "google_bigquery_table" "table" {
    dataset_id = var.dataset_id
    table_id   = var.table_id
    schema     = file("../schemas/airflow_schema.json")
    deletion_protection = false
}