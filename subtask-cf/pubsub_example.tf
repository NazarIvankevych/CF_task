terraform {
  backend "gcs" {
    prefix = "pubsub-task"
  }
}

variable "project_id" {
  type        = string
  description = "Project ID to deploy resources in."
}

module "cf_subtask_ps_topic" {
  project_id = var.project_id
  name       = "cf-subtask-ps-topic"
}

module "cf_subtask_ps_subscription" {
  project_id                       = var.project_id
  name                             = "cf-subtask-ps-topic-sub"
  topic                            = module.cf_subtask_ps_topic.topic_id
  enable_monitoring                = false
  max_undelivered_threshold        = 8000
  max_undelivered_duration         = "3600s"
  max_oldest_unacked_age_threshold = 86400 # 1 day
  max_oldest_unacked_age_duration  = "3600s"
}
