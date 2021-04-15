data "archive_file" "iex-api-file" {
  source_dir = "../iex-stream/cloud_functions/iex_api"
  output_path = "../cloud_functions/iex_api.zip"
  type = "zip"
}

resource "google_storage_bucket_object" "iex-api-source" {
  name = format("%s-%s.zip", "cloud_functions/iex_api", data.archive_file.iex-api-file.output_md5)
  bucket = var.gcs_code_bucket
  source = data.archive_file.iex-api-file.output_path
}

resource "google_cloudfunctions_function" "iex-api" {
  name = "iex-api"
  available_memory_mb = 256
  source_archive_bucket = google_storage_bucket_object.iex-api-source.bucket
  source_archive_object = google_storage_bucket_object.iex-api-source.name
  entry_point = "event_handler"
  runtime = "python37"
  timeout = 90
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource = google_pubsub_topic.iex-ingest.name
  }
  environment_variables = {
    "PROJECT_ID" = var.project_id
    "INPUT_TOPIC" = google_pubsub_topic.iex-ingest.id
    "OUTPUT_TOPIC" = google_pubsub_topic.iex-aggregate.id
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker-iex-api" {
  project        = google_cloudfunctions_function.iex-api.project
  region         = "europe-west2"
  cloud_function = google_cloudfunctions_function.iex-api.name
  role = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
