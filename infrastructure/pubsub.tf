resource "google_pubsub_topic" "iex-ingest" {
  name = "iex-ingest"
  message_storage_policy {
    allowed_persistence_regions = ["europe-west2"]
  }
}

resource "google_pubsub_topic" "iex-aggregate" {
  name = "iex-aggregate"
  message_storage_policy {
    allowed_persistence_regions = ["europe-west2"]
  }
}

resource "google_pubsub_subscription" "iex-aggregate-subscription-1" {
  name = "iex-aggregate-1"
  topic = google_pubsub_topic.iex-aggregate.name
  message_retention_duration = "1800s"
  retain_acked_messages      = true
  ack_deadline_seconds = 30
  expiration_policy {
    ttl = "300000s"
  }
}

resource "google_pubsub_subscription" "iex-aggregate-subscription-5" {
  name = "iex-aggregate-5"
  topic = google_pubsub_topic.iex-aggregate.name
  message_retention_duration = "1800s"
  retain_acked_messages      = true
  ack_deadline_seconds = 30
  expiration_policy {
    ttl = "300000s"
  }
}

resource "google_pubsub_subscription" "iex-aggregate-subscription-15" {
  name = "iex-aggregate-15"
  topic = google_pubsub_topic.iex-aggregate.name
  message_retention_duration = "1800s"
  retain_acked_messages      = true
  ack_deadline_seconds = 30
  expiration_policy {
    ttl = "300000s"
  }
}
