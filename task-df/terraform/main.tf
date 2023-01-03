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
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_storage_bucket_object" "zip" {
  source = data.archive_file.source.output_path
  content_type = "application/zip"
  name = "src-${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.task-cf-bucket.name

  depends_on = [
    google_storage_bucket.task-cf-bucket,
    data.archive_file.source
  ]
}

resource "google_bigquery_dataset" "dataflow-cf-dataset" {
  dataset_id  = var.dataset_id
  description = "This dataset is public"
  location    = "US"
}

resource "google_bigquery_table" "dataflow-cf-table" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = file("../schemas/dataflow-cf-raw.json")

  depends_on = [
    google_bigquery_dataset.task-cf-dataset
  ]
}

resource "google_bigquery_table" "dataflow-cf-error-table" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = file("../schemas/dataflow-cf-error-raw.json")

  depends_on = [
    google_bigquery_dataset.task-cf-dataset
  ]
}

resource "google_cloudfunctions_function" "task-cf-function" {
  name = "task-cf-function"
  runtime             = "python38"

  source_archive_bucket = google_storage_bucket.task-cf-bucket.name
  source_archive_object = google_storage_bucket_object.zip.name
  
  entry_point         = "main"
  trigger_http = true
  
  available_memory_mb = 128
  timeout = 60

  # environment_variables = {
  #   FUNCTION_REGION = var.region
  #   GCP_PROJECT = var.project_id
  #   DATASET_ID = var.dataset_id
  #   OUTPUT_TABLE = google_bigquery_table.task-cf-table.table_id
  # }

  depends_on = [
    google_bigquery_dataset.task-cf-dataset,
    google_storage_bucket.task-cf-bucket,
    google_storage_bucket_object.zip
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.task-cf-function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudbuild_trigger" "github-dataflow-trigger" {
  project = var.project_id
  name = "github-updates-dataflow-trigger"
  filename = "cloudbuild.yaml"
  location = "us-central1"
  github {
    owner = "nazarivankevych"
    name = "cf_task/dataflow"
    push {
      branch = "dataflow"
    }
  }
}