# -------------------------------------------------------------------
# PROVIDER
# -------------------------------------------------------------------

provider "google" {
  project = var.project_id
  credentials = var.gcp_credentials
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  credentials = var.gcp_credentials
  region  = var.region
}