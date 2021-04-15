provider "google" {
  project = "iex-stream"
  region  = "europe-west2"
}

terraform  {
  backend "gcs" {
    bucket = "iex-stream-code"
    prefix = "terraform-state"
  }
}