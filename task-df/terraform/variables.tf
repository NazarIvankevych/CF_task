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

variable "zone" {
    default     = "us-central1-c"
    type        = string
    description = "Zone"
}

variable "dataset_id" {
    default     = "task_cf_dataset"
    type        = string
    description = "Dataset ID"
}

variable "table_id" {
    default     = "table-df-table-dataflow"
    type        = string
    description = "Table dataflow task ID"
}

variable "table-error_id" {
    default     = "table-df-table-dataflow-error"
    type        = string
    description = "Table dataflow-error task ID"
}

variable "deletion_protection" {
    default = false
}

variable "force_destroy" {
    default = true
}

variable "bucket_id" {
    type = string
    default = "cf-task-nazar"
}

variable "topic_id" {
    type = string
    default = "cf-pub_sub-topic"
}

variable "subscription_id" {
    type = string
    default = "cf-pub_sub-subscription"
}
