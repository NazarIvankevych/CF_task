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
  name = "${var.project_id}-dataflow-bucket"
  location = var.region
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket_object" "task-df-object" {
  source   = data.archive_file.task-df-source.output_path
  content_type = "application/zip"
  name = "src-${data.archive_file.task-df-source.output_md5}.task-df-object"
  bucket = google_storage_bucket.task-df-bucket.name
    depends_on = [
      google_storage_bucket.task-df-bucket,
      data.archive_file.task-df-source
  ]
}

resource "google_bigquery_dataset" "task-df-dataset" {
  dataset_id  = var.dataset_id
  description = "This dataset is public"
  location    = var.location
}

resource "google_bigquery_table" "dataflow-df-table" {
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema     = file("../schemas/dataflow-cf-raw.json")
  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.task-df-dataset
  ]
}

resource "google_bigquery_table" "dataflow-df-error-table" {
  dataset_id = var.dataset_id
  table_id   = var.table-error_id
  schema     = file("../schemas/dataflow-cf-error-raw.json")
  deletion_protection = false

  depends_on = [
    google_bigquery_dataset.task-df-dataset
  ]
}

resource "google_pubsub_topic" "df-ps-topic" {
  project = var.project_id
  name = var.topic_id
}

resource "google_pubsub_subscription" "df-ps-subscription" {
  project = var.project_id
  name                             = var.subscription_id
  topic                            = google_pubsub_topic.df-ps-topic.name
}

resource "google_pubsub_topic_iam_member" "member" {
  project = google_pubsub_topic.df-ps-topic.project
  topic = google_pubsub_topic.df-ps-topic.name
  role = "roles/owner"
  member = "allUsers"
}

resource "google_pubsub_subscription_iam_member" "sub-owner" {
  subscription = google_pubsub_subscription.df-ps-subscription.name
  role = "roles/owner"
  member = "allUsers"
}

resource "google_dataflow_job" "big_data_job" {
  name                  = "dataflow-job"
  template_gcs_path     = "gs://task-cf-370710-dataflow-bucket/template/dataflow-job"
  temp_gcs_location     = "gs://task-cf-370710-dataflow-bucket/tmp"
  service_account_email = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_trigger" "dataflow-trigger" {
  project = var.project_id
  name = "task-df-trigger"
  filename = "task-df/cloudbuild.yaml"
  github {
    owner = "nazarivankevych"
    name = "cf_task"
    push {
      branch = "^master$"
    }
  }
}