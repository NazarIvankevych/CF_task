variable "project_id" {
    default     = "task-cf-370710"
    type        = string
    description = "Project ID to deploy resources in."
}

variable "region" {
    default     = "us-central1"
    type        = string
    description = "Region"
}

variable "zone" {
    default     = "us-central1-c"
    type        = string
    description = "Zone"
}

variable "bucket_id" {
    type = string
    default = "task-cf-370710-bucket"
}

variable "topic_id" {
    type = string
    default = "cf-pub_sub-topic"
}

variable "subscription_id" {
    type = string
    default = "cf-pub_sub-subscription"
}