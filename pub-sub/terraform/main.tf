terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.44.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
}

resource "google_pubsub_topic" "cf_subtask_ps_topic" {
  name = var.topic_id
}

resource "google_pubsub_subscription" "cf_subtask_ps_subscription" {
  name                             = var.subscription_id
  topic                            = google_pubsub_topic.cf_subtask_ps_topic.name
}

# resource "google_cloudbuild_trigger" "pubsub-config-trigger" {
#   location    = var.region
#   name        = "${var.project_id}-pubsub-trigger"
#   description = "acceptance test example pubsub build trigger"
#   filename = "pubsub_publisher"

#   pubsub_config {
#     topic = google_pubsub_topic.cf_subtask_ps_topic.id
#   }
# }



# resource "google_cloudbuild_trigger" "github-trigger" {
#   # location = var.region

#   project  = var.project_id
#   name     = "github-updates-trigger"
#   filename = "cloudbuild.yaml"
#   github {
#     owner = " NazarIvankevych"
#     name  = "CF_task"
#     push {
#       branch = "^master$"
#     }
#   }
# }
