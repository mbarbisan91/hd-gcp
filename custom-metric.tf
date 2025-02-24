resource "google_monitoring_metric_descriptor" "custom_metric" {
  type         = "custom.googleapis.com/http_requests"  # Definimos el tipo de métrica
  display_name = "HTTP Requests Count"
  description  = "Custom metric for counting HTTP requests"
  metric_kind  = "CUMULATIVE"
  value_type   = "INT64"

  labels {
    key         = "method"
    value_type  = "STRING"
    description = "HTTP method (GET, POST, etc.)"
  }

  unit = "1"
}