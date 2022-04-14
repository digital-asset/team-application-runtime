terraform {
  backend "gcs" {
    # Manually created bucket
    # Ideally everything else in the project is created by this tf config
    bucket = "daml-app-runtime-tfstate"
    # Using repo name as folder in case we ever need tf configs in other repos
    prefix = "team-application-runtime"
  }
}

provider "google" {
  project = "daml-app-runtime"
  region  = "us-east4"
  zone    = "us-east4-a"
}

data "google_project" "current" {}

resource "google_storage_bucket" "ci-state" {
  name     = "daml-app-runtime-ci-state"
  location = "us-east4"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_acl" "data" {
  bucket = google_storage_bucket.ci-state.name

  role_entity = [
    "OWNER:project-owners-${data.google_project.current.number}",
    "OWNER:project-editors-${data.google_project.current.number}",
    "READER:project-viewers-${data.google_project.current.number}",
  ]
}

resource "google_service_account" "ci" {
  # must be at least 4 characters
  account_id   = "ci-account"
  display_name = "CI Writer"
}

// allow rw access for CI
resource "google_storage_bucket_iam_member" "ci-state" {
  for_each = toset(["objectCreator", "objectViewer"])
  bucket   = google_storage_bucket.ci-state.name

  # https://cloud.google.com/storage/docs/access-control/iam-roles
  role   = "roles/storage.${each.key}"
  member = "serviceAccount:${google_service_account.ci.email}"
}

resource "google_service_account_key" "ci-keys" {
  service_account_id = google_service_account.ci.name
  // "Arbitrary map of values that, when changed, will trigger a new key to be
  // generated."
  keepers = {
    generated_on = "2022-04-13"
  }
}

# Prints private key so it can be set in CI as env var
output "ci_key" {
  value = nonsensitive(google_service_account_key.ci-keys.private_key)
}
