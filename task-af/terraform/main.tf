terraform {
    backend "gcs" {
        prefix = "task-af"
        bucket = "big-data-bucket125478"
    }
}

provider "google" {
    # Configuration options
    project = var.project_id
    region = var.region
}

resource "google_storage_bucket" "bucket" {
    name     = "${var.project_id}-airflow-bucket"
    location = var.location
    force_destroy = true
}

resource "google_bigquery_table" "airflow_table" {
    dataset_id = var.dataset_id
    table_id   = var.table_id
    schema     = file("../schemas/airflow_schema.json")
    deletion_protection = false
}

resource "google_cloudbuild_trigger" "airflow-trigger" {
    project = var.project_id
    name = "task-af-trigger"
    filename = "task-af/cloudbuild.yaml"
    github {
        owner = "nazarivankevych"
        name = "cf_task"
        push {
            branch = "^task-airflow$"
    }
    }
    substitutions = {
        "_APP": "task-af"
        "_COMPOSER_ENV_NAME": var.af-composer-name,
        "_COMPOSER_LOCATION": var.af-composer-location,
    }
}
