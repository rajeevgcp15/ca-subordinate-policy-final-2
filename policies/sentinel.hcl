module "tfplan-functions" {
    source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "generic-functions" {
    source = "../common-functions/generic-functions/generic-functions.sentinel"
}

policy "appsec_gcp_serviceaccount_restriction" {
    source = "./appsec_gcp_serviceaccount_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "assetmgmt_gcp_naming_validation" {
    source = "./assetmgmt_gcp_naming_validation.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "assetmgmt_gcp_resiliency_validation" {
    source = "./assetmgmt_gcp_resiliency_validation.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "compute_gcp_gke_notify" {
    source = "./compute_gcp_gke_notify.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "compute_gcp_versioning_enforce" {
    source = "./compute_gcp_versioning_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "encryption_gcp_cmek_enforce" {
    source = "./encryption_gcp_cmek_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "iam_gcp_identity_enforce" {
    source = "./iam_gcp_identity_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "iam_gcp_policy_restrictions" {
    source = "./iam_gcp_policy_restrictions.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_dns_log_enforce" {
    source = "./network_gcp_dns_log_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_enforce_service_access" {
    source = "./network_gcp_enforce_service_access.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_ip_restriction" {
    source = "./network_gcp_ip_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_mtu_restriction" {
    source = "./network_gcp_mtu_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_port_restriction" {
    source = "./network_gcp_port_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_region_restricition" {
    source = "./network_gcp_region_restricition.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_ssl_enforce" {
    source = "./network_gcp_ssl_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_subnet_log_enforce" {
    source = "./network_gcp_subnet_log_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_subnet_route_restriction" {
    source = "./network_gcp_subnet_route_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "network_gcp_traffic_enforce" {
    source = "./network_gcp_traffic_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "storage_gcp_sql_versioning_enforce" {
    source = "./storage_gcp_sql_versioning_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "storage_gcp_versioning_enforce" {
    source = "./storage_gcp_versioning_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "tagging_gcp_validation" {
    source = "./tagging_gcp_validation.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "threat_gcp_data_configuration_restriction" {
    source = "./threat_gcp_data_configuration_restriction.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "threat_gcp_kms_enforce" {
    source = "./threat_gcp_kms_enforce.sentinel"
    enforcement_level = "hard-mandatory"
}
policy "threat_gcp_unapproved_service_validation" {
    source = "./threat_gcp_unapproved_service_validation.sentinel"
    enforcement_level = "hard-mandatory"
}

param "org" {
  value = [ "wf" ]
}

param "country" {
  value = [ "us" ]
}

param "gcp_region" {
  value = [ "US" ]
}

param "owner" {
  value = ["hybridenv"] 
}

param "application_division" {
  value =  ["pci", "paa", "hdpa", "hra", "others"]
}

param "application_name" {
  value =  ["app1","demo"]
}

param "application_role" {
  value = ["app", "web", "auth", "data"]
}

param "environment" {
  value =   ["prod", "nonprod", "sandbox", "core"] 
}

param "au" {
  value = [ "0223092" ]
}

param "prefix" {
    value = "us-"
}
