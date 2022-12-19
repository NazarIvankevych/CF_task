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

resource "google_pubsub_topic" "cf_subtask_ps_topic" {
  name = "cf_subtask_ps_topic"  
}

resource "google_cloudbuild_trigger" "pubsub-config-trigger" {
  location    = var.region
  name        = "${var.project_id}-pubsub-trigger"
  description = "acceptance test example pubsub build trigger"
  filename = "pubsub_publisher"

  pubsub_config {
    topic = google_pubsub_topic.cf_subtask_ps_topic.id
  }
}

resource "google_pubsub_subscription" "cf_subtask_ps_subscription" {
  name                             = "cf-subtask-ps-topic-sub"
  topic                            = google_pubsub_topic.cf_subtask_ps_topic.name
  # push_config {
  #   push_endpoint = "https://example.com/push"

  #   attributes = {
  #     x-goog-version = "v1"
  #   }
  # }
}
