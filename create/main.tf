terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.81.0"
    }
  }
}

resource "google_sql_database_instance" "instance" {
  name             = "bug-412-2023-09-07"
  database_version = "POSTGRES_11"
  region           = "us-central1"

  settings {
    tier            = "db-g1-small"
		backup_configuration {
			enabled = false
		}
  }

  deletion_protection = false
}
