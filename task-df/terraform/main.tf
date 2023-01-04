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

resource "google_project_iam_member" "my-project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:nazar.ivankevych@gmail.com"
}

resource "google_project_iam_member" "cloud-build-project" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_storage_bucket" "task-df-bucket" {
  name     = "dataflow-bucket"
  location = var.region
}

resource "google_storage_bucket_object" "task-df-object" {
  name   = data.archive_file.task-df.output_path
  content_type = "application/zip"
  name = "src-${data.archive_file.task-df.output_md5}.cf-tasks"
  bucket = google_storage_bucket.task-df-bucket.name
    depends_on = [
      google_storage_bucket.task-df-bucket,
      data.archive_file.task-df
  ]
}

resource "google_bigquery_dataset" "task-df-dataset" {
  dataset_id  = var.dataset_id
  description = "This dataset is public"
  location    = var.region
}

resource "google_bigquery_table" "dataflow-df-table" {
  dataset_id = var.dataset_id
  table_id   = var.table-dataflow_id
  schema     = file("../schemas/dataflow-cf-raw.json")

  depends_on = [
    google_bigquery_dataset.task-df-dataset
  ]
}

resource "google_bigquery_table" "dataflow-df-error-table" {
  dataset_id = var.dataset_id
  table_id   = var.table-error-dataflow_id
  schema     = file("../schemas/dataflow-cf-error-raw.json")

  depends_on = [
    google_bigquery_dataset.task-df-dataset
  ]
}

resource "google_cloudfunctions_function" "task-df-function" {
  name        = "task-df-function"
  description = "Dataflow"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.task-df-bucket.name
  source_archive_object = google_storage_bucket_object.task-df-object.name
  trigger_http          = true
  entry_point           = "main"

  environment_variables = {
      FUNCTION_REGION = var.region
      GCP_PROJECT = var.project_id
      DATASET_ID = var.dataset_id
      OUTPUT_TABLE = google_bigquery_table.dataflow-df-table.table_id
    }

  depends_on = [
    google_bigquery_dataset.task-df-dataset,
    google_storage_bucket.task-df-bucket,
    google_storage_bucket_object.task-df-object
  ]
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.task-df-function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_dataflow_job" "big_data_job" {
  name                  = "dataflow-job-task"
  template_gcs_path     = "gs://cf-task/template/test-job"
  temp_gcs_location     = "gs://cf-task/tmp"
  service_account_email = "cloud-builder-account@task-cf-370710.iam.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "github-dataflow-trigger" {
  project = var.project_id
  name = "github-updates-task_df-trigger"
  filename = "cloudbuild.yaml"
  location = "us-central1"
  github {
    owner = "nazarivankevych"
    name = "cf-task"
    push {
      branch = "dataflow"
    }
  }
}