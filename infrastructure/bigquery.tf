resource "google_bigquery_dataset" "iex" {
  dataset_id = "iex"
  location = "europe-west2"
}

resource "google_bigquery_table" "quote" {
  dataset_id = google_bigquery_dataset.iex.dataset_id
  table_id   = "quote"
  time_partitioning {
    type = "DAY"
  }
  schema = <<EOF
[
  {
    "name": "symbol",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "latest_price",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "window_end",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "event_time",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "resolution_minutes",
    "type": "INTEGER",
    "mode": "NULLABLE"
  }
]
EOF
}

resource "google_bigquery_table" "top_stocks" {
  dataset_id = google_bigquery_dataset.iex.dataset_id
  table_id = "top_stocks"
  view {
    use_legacy_sql = false
    query = <<SQL
WITH mean as
(
    SELECT resolution_minutes, window_end, symbol, SUM(latest_price) / COUNT(latest_price) AS mean_price
    FROM `iex-stream.iex.quote`
    WHERE window_end < current_timestamp()
    GROUP BY resolution_minutes, window_end, symbol
)
SELECT *
FROM
    (SELECT *, rank() OVER (PARTITION BY resolution_minutes, window_end ORDER BY mean_price DESC) as value_rank
     FROM mean)
WHERE value_rank <= 3
ORDER BY window_end DESC
;
SQL
  }
}

resource "google_bigquery_table" "percentage_gain" {
  dataset_id = google_bigquery_dataset.iex.dataset_id
  table_id = "percentage_gain"
  view {
    use_legacy_sql = false
    query = <<SQL
WITH extrema AS
(
    SELECT symbol, window_end, resolution_minutes, MAX(event_time) AS latest, MIN(event_time) AS earliest
    FROM `iex-stream.iex.quote`
    WHERE window_end < current_timestamp()
    GROUP BY symbol, window_end, resolution_minutes
)
SELECT e.symbol, e.window_end, e.resolution_minutes, 100*(a.latest_price - b.latest_price) / b.latest_price as percentage_gain
FROM extrema e
INNER JOIN `iex-stream.iex.quote` a
ON a.event_time = e.latest
AND a.symbol = e.symbol
AND a.window_end = e.window_end
AND a.resolution_minutes = e.resolution_minutes
INNER JOIN `iex-stream.iex.quote` b
ON b.event_time = e.earliest
AND b.symbol = e.symbol
AND b.window_end = e.window_end
AND b.resolution_minutes = e.resolution_minutes
ORDER BY e.window_end DESC
;
SQL
  }
}