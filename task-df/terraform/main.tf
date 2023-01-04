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

resource "google_dataflow_job" "big_data_job" {
  name                  = "dataflow-job-task"
  template_gcs_path     = "gs://cf-task/template/test-job"
  temp_gcs_location     = "gs://cf-task/tmp"
  service_account_email = "cloud-builder-account@task-cf-370710.iam.gserviceaccount.com"
}
