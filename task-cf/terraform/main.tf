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

resource "google_storage_bucket" "task-cf-bucket" {
  name = "${var.project_id}-bucket"
  location = var.region
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket_object" "cf-tasks" {
  source = data.archive_file.cf-task.output_path
  content_type = "application/zip"
  name = "src-${data.archive_file.cf-task.output_md5}.cf-tasks"
  bucket = google_storage_bucket.task-cf-bucket.name

  depends_on = [
    google_storage_bucket.task-cf-bucket,
    data.archive_file.cf-task
  ]
}

resource "google_storage_bucket_object" "dataflow" {
  source = data.archive_file.dataflow.output_path
  content_type = "application/zip"
  name = "src-${data.archive_file.dataflow.output_md5}.dataflow"
  bucket = google_storage_bucket.task-cf-bucket.name

  depends_on = [
    google_storage_bucket.task-cf-bucket,
    data.archive_file.dataflow
  ]
}

resource "google_bigquery_dataset" "task-cf-dataset" {
  dataset_id  = var.dataset_id
  description = "This dataset is public"
  location    = "US"
}

resource "google_bigquery_table" "task-cf-table" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = file("../schemas/bq_table_schema/task-cf-raw.json")
  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.task-cf-dataset
  ]
}

resource "google_bigquery_table" "dataflow-cf-table" {
  dataset_id = var.dataset_id
  table_id   = var.dataflow_id
  schema     = file("../schemas/bq_table_schema/dataflow-cf-raw.json")
  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.task-cf-dataset
  ]
}

resource "google_bigquery_table" "dataflow-cf-error-table" {
  dataset_id = var.dataset_id
  table_id   = var.dataflow-error_id
  schema     = file("../schemas/bq_table_schema/dataflow-cf-error-raw.json")
  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.task-cf-dataset
  ]
}

resource "google_pubsub_topic" "cf-subtask-ps-topic" {
  project = var.project_id
  name = var.topic_id
}

resource "google_pubsub_topic_iam_member" "member" {
  project = google_pubsub_topic.cf-subtask-ps-topic.project
  topic = google_pubsub_topic.cf-subtask-ps-topic.name
  role = "roles/owner"
  member = "allUsers"
}

resource "google_pubsub_subscription" "cf-subtask-ps-subscription" {
  project = var.project_id
  name                             = var.subscription_id
  topic                            = google_pubsub_topic.cf-subtask-ps-topic.name
}

resource "google_pubsub_subscription_iam_member" "sub-owner" {
  subscription = google_pubsub_subscription.cf-subtask-ps-subscription.name
  role = "roles/owner"
  member = "allUsers"
}

resource "google_cloudfunctions_function" "task-cf-function" {
  name = "cf-tasks-function"
  runtime             = "python38"

  source_archive_bucket = google_storage_bucket.task-cf-bucket.name
  source_archive_object = google_storage_bucket_object.cf-tasks.name
  
  entry_point         = "main"
  trigger_http = true
  
  available_memory_mb = 128
  timeout = 60

  environment_variables = {
    FUNCTION_REGION = var.region
    GCP_PROJECT = var.project_id
    DATASET_ID = var.dataset_id
    OUTPUT_TABLE = google_bigquery_table.task-cf-table.table_id
  }

  depends_on = [
    google_bigquery_dataset.task-cf-dataset,
    google_pubsub_topic.cf-subtask-ps-topic,
    google_storage_bucket.task-cf-bucket,
    google_storage_bucket_object.cf-tasks,
    google_storage_bucket_object.dataflow
  ]
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = var.project_id
  region         = var.region
  cloud_function = google_cloudfunctions_function.task-cf-function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

resource "google_cloudbuild_trigger" "github-trigger" {
  project = var.project_id
  name = "github-updates-trigger"
  filename = "cloudbuild.yaml"
  location = "us-central1"
  github {
    owner = "nazarivankevych"
    name = "cf_task"
    push {
      branch = "^master"
    }
  }
}

resource "google_cloudbuild_trigger" "github-dataflow-trigger" {
  project = var.project_id
  name = "github-updates-dataflow-trigger"
  filename = "cloudbuild.yaml"
  location = "us-central1"
  github {
    owner = "nazarivankevych"
    name = "cf_task"
    push {
      branch = "dataflow"
    }
  }
}
