resource "google_cloud_scheduler_job" "aapl" {
  name = "aapl"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "AAPL"
    }))
  }
}

resource "google_cloud_scheduler_job" "amzn" {
  name = "AMZN"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "AMZN"
    }))
  }
}

resource "google_cloud_scheduler_job" "gme" {
  name = "GME"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "GME"
    }))
  }
}

resource "google_cloud_scheduler_job" "fslr" {
  name = "FSLR"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "FSLR"
    }))
  }
}

resource "google_cloud_scheduler_job" "tsla" {
  name = "TSLA"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "TSLA"
    }))
  }
}

resource "google_cloud_scheduler_job" "nio" {
  name = "NIO"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "NIO"
    }))
  }
}

resource "google_cloud_scheduler_job" "goog" {
  name = "GOOG"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "GOOG"
    }))
  }
}

resource "google_cloud_scheduler_job" "msft" {
  name = "MSFT"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "MSFT"
    }))
  }
}

resource "google_cloud_scheduler_job" "amc" {
  name = "AMC"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "AMC"
    }))
  }
}

resource "google_cloud_scheduler_job" "bbby" {
  name = "BBBY"
  schedule = "* * * * *"
  pubsub_target {
    topic_name = google_pubsub_topic.iex-ingest.id
    data = base64encode(jsonencode({
      "ticker": "BBBY"
    }))
  }
}
