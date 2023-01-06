variable "project_id" {
    default     = "task-cf-370710"
    type        = string
    description = "Project ID"
}

variable "region" {
    default     = "us-central1"
    type        = string
    description = "Region"
}

variable "location" {
    default     = "US"
    type        = string
    description = "Location"
}

variable "dataset_id" {
    default     = "task_cf_dataset"
    type        = string
    description = "Dataset ID"
}

variable "table_id" {
    default     = "cf-tasks-table"
    type        = string
    description = "Table cf-task task ID"
}

variable "deletion_protection" {
    default = false
}

variable "force_destroy" {
    default = true
}

variable "topic_id" {
    type = string
    default = "cf-pub_sub-topic"
}

variable "subscription_id" {
    type = string
    default = "cf-pub_sub-subscription"
}