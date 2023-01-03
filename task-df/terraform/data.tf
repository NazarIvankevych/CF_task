data "archive_file" "source" {
    type        = "zip"
    source_dir = "../function"
    output_path = "/tmp/dataflow_function.zip"
}