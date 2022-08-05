# Required Google APIs
locals {
  googleapis = ["privateca.googleapis.com", "storage.googleapis.com", "cloudkms.googleapis.com"]
}
# Enable required services
resource "google_project_service" "apis" {
  for_each           = toset(local.googleapis)
  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}
# Create a service account to the CA service
resource "google_project_service_identity" "privateca_sa" {
  provider = google-beta
  service  = "privateca.googleapis.com"
  project  = "modular-scout-345114"
}

# Grant access to the CA Pool
resource "google_privateca_ca_pool_iam_member" "policy" {
  ca_pool = google_privateca_ca_pool.example_ca_pool_enterprise.id
  role    = "roles/privateca.certificateManager"
  member  = "serviceAccount:${google_project_service_identity.privateca_sa.email}"
}  

#creation of CA pool with teir as Enterprise
resource "google_privateca_ca_pool" "example_ca_pool_enterprise" {
  name     = "my-pool-x1"
  location = "us-central1"
  tier     = "ENTERPRISE"
  labels = {
    foo = "bar"
  }
  issuance_policy {
    identity_constraints {
      allow_subject_passthrough           = true
      allow_subject_alt_names_passthrough = true
      cel_expression {
        expression = "subject_alt_names.all(san, san.type == DNS || san.type == EMAIL )"
        title      = "My title"
      }
   }
    
  }
}

resource "google_privateca_certificate_authority" "root-ca" {
  pool                     = "${google_privateca_ca_pool.example_ca_pool_enterprise.name}"
  certificate_authority_id = "my-certificate-authority-root2"
  location                 = "us-central1"
  deletion_protection      = false
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name  = "my-certificate-authority"
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = false
          email_protection = true
          code_signing     = true
          time_stamping    = true
        }
      }
    }
  }
  lifetime = "86400s"
  key_spec {
    algorithm = "RSA_PSS_2048_SHA256"
   # cloud_kms_key_version = trimprefix(data.google_kms_crypto_key_version.secret_version.name, "//cloudkms.googleapis.com/v1/")
  }
  type       = "SELF_SIGNED"
}

resource "google_privateca_certificate_authority" "subordinate" {
  // This example assumes this pool already exists.
  // Pools cannot be deleted in normal test circumstances, so we depend on static pools
  pool                     = "${google_privateca_ca_pool.example_ca_pool_enterprise.name}"
  certificate_authority_id = "my-certificate-authority-sub3"
  location                 = "us-central1"
  deletion_protection      = false
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name  = "my-certificate-authority"
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 10
      }
      key_usage {
        base_key_usage {
          digital_signature  = true
          content_commitment = true
          key_encipherment   = false
          data_encipherment  = true
          key_agreement      = true
          cert_sign          = true
          crl_sign           = true
          decipher_only      = true
        }
        extended_key_usage {
          server_auth      = true
          client_auth      = false
          email_protection = true
          code_signing     = true
          time_stamping    = true
        }
      }
    }
  }
  lifetime = "86400s"
  key_spec {
    algorithm = "RSA_PSS_2048_SHA256"
    #cloud_kms_key_version = trimprefix(data.google_kms_crypto_key_version.secret_version.name, "//cloudkms.googleapis.com/v1/")
  }
  type       = "SUBORDINATE"
   subordinate_config {
    certificate_authority = google_privateca_certificate_authority.root-ca.name
  }
}


