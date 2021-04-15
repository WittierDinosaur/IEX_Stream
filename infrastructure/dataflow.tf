resource "google_dataflow_job" "pubsub-stream-1" {
    name = "iex-aggregate-1"
    template_gcs_path = "gs://${var.gcs_code_bucket}/dataflow/templates/iex-aggregate-1"
    temp_gcs_location = "gs://${var.gcs_code_bucket}/dataflow/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
}

resource "google_dataflow_job" "pubsub-stream-5" {
    name = "iex-aggregate-5"
    template_gcs_path = "gs://${var.gcs_code_bucket}/dataflow/templates/iex-aggregate-5"
    temp_gcs_location = "gs://${var.gcs_code_bucket}/dataflow/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
}

resource "google_dataflow_job" "pubsub-stream-15" {
    name = "iex-aggregate-15"
    template_gcs_path = "gs://${var.gcs_code_bucket}/dataflow/templates/iex-aggregate-15"
    temp_gcs_location = "gs://${var.gcs_code_bucket}/dataflow/temp"
    enable_streaming_engine = true
    on_delete = "cancel"
}