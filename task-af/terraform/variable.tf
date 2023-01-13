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

variable "bucket_id" {
  type = string
  default = "task-af-airlfow-254789"
}

variable "dataset_id" {
    default     = "task_af_dataset"
    type        = string
    description = "Dataset ID"
}

variable "table_id" {
    default     = "table-af-airflow"
    type        = string
    description = "Table airflow task ID"
}

variable "deletion_protection" {
    default = false
}

variable "force_destroy" {
    default = true
}
