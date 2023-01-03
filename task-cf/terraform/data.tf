data "google_project" "project" {}

data "google_service_account" "cloudbuild_account" {
    account_id = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

data "archive_file" "task-cf" {
    type        = "zip"
    source_dir = "../function"
    output_path = "/tmp/function.zip"
}

# data "archive_file" "dataflow" {
#     type        = "zip"
#     source_dir = "../function/dataflow-functions/"
#     output_path = "/tmp/dataflow_function.zip"
# }