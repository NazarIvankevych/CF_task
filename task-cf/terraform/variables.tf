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
    default     = "task_cf_table"
    type        = string
    description = "Table task ID"
}

variable "deletion_protection" {
    default = false
}

variable "force_destroy" {
    default = true
}