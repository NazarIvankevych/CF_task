data "google_project" "project" {}

data "google_service_account" "cloudbuild_account" {
    account_id = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

data "archive_file" "task-df-source" {
    type        = "zip"
    source_dir = "../function"
    output_path = "/tmp/function.zip"
}
