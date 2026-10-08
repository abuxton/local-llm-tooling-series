resource "terraform_data" "baseline" {
  input = {
    purpose     = "local-llm-tooling-series"
    environment = "non-production"
  }
}

output "safety_boundary" {
  value = "This fixture has no provider, backend, credentials, or apply target."
}
