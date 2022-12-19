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
