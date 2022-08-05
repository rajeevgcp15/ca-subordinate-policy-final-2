### network_gcp_ip_restriction.sentinel
```
GCP_INTERNAL_IP: As per policy, Internal IPs will be enabled only, no communication thorugh external ip addresses.
```

#### Imports
```
import "strings"
import "types"
import "tfplan-functions" as plan
import "generic-functions" as gen
```

#### Variables 
|Name|Description|
|----|-----|
|selected_node|It is being used locally to have information of node by passing the path.|
|messages| It is being used to hold the complete message of policies violation to show to the user.|

#### Maps
The below map is having entries of the GCP resources in key/value pair, those are required to be validated for ip restriction policy. Key will be name of the GCP terraform resource ("https://registry.terraform.io/providers/hashicorp/google/latest/docs") and its value will be list of maps hows attributes to be validated as per policy again these are combination of key/value pair. Map '''key''' description mentioned below

|Key Name|Description|
|----|-----|
|key|value will be the path of attribute to be validated as per policy defination.|
|expected_result| value will be expected result which is of boolean or string type|
|is_composer_cidr| Added to check if it of google_composer_environment resource cidr, value will boolean true or false  |
|cidr_disp_message| If is_composer_cidr is true then value of this will be displayed and it is of string type|

In order to validate, just need to add corresponding entry of particular GCP terraform resource in the below map as given for google_dataproc_cluster or google_container_cluster or google_composer_environment or example_rsc.
```
resourceTypesInternalIPMap = {
	"google_dataproc_cluster": [{
		"key":             "cluster_config.0.gce_cluster_config.0.internal_ip_only",
		"expected_result": true,
		"is_composer_cidr": false,
	}],
	"google_container_cluster": [{
		"key":             "private_cluster_config.0.enable_private_nodes",
		"expected_result": true,
		"is_composer_cidr": false,
	},
    {
        "key":             "private_cluster_config.0.enable_private_endpoint",
        "expected_result": true,
		"is_composer_cidr": false,
    }],
	"google_composer_environment": [
	{
		"key":             "config.0.private_environment_config.0.enable_private_endpoint",
		"expected_result": true,
		"is_composer_cidr": false,
	},
	{
		"key":             "config.0.master_authorized_networks_config.0.cidr_blocks.0.cidr_block",
		"expected_result": true,
		"is_composer_cidr": true,
		"cidr_disp_message": "CIDR block must be defined under master_authorized_networks_config - cidr_blocks attribute for resource ",
	}],
    "example_rsc": [{
		"key":             "someroot.internal_ip_only",
		"expected_result": "mention the expected result",
		"is_composer_cidr": "true/false",
		"cidr_disp_message": "If is_composer_cidr is true we need to mention the cidr display name"
	}],
}


```

#### Methods
The below function is being used to validate the value of parameter as per the policy, its value needs to be true and it can not be empty/null. If the policy won't be validated successfully, it will generate appropriate message to show the users. This function will have below 2-parameters:

* Parameters

  |Name|Description|
  |----|-----|
  |address|The key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |rc|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock.|

  ```
	check_internal_ip = func(address, rc) {
		map_results = resourceTypesInternalIPMap[rc.type]
		msg_list = null

		for map_results as rec {
			selected_node = plan.evaluate_attribute(rc, rec.key)
			selected_node_result = rec.expected_result		
			is_composer_cidr = rec.is_composer_cidr

			if types.type_of(selected_node) is "null" or types.type_of(selected_node) is "undefined" {
				if msg_list is null {
					msg_list = []
				}

				if is_composer_cidr is true {
					append(msg_list, rec.cidr_disp_message + address)
				} else {
					append(msg_list, "It does not have " + rec.key + " defined.")
				}
			} else {
				if selected_node is not selected_node_result and is_composer_cidr is not true {
					if msg_list is null {
						msg_list = []
					}
					append(msg_list, "The service should be accessible through internal ip only, please set value of " + rec.key + " to " + plan.to_string(selected_node_result) + " to make it as per requirement.")
				}
				
			}
		}
		return msg_list
	}
  ```

#### Working Code
The below code will iterate each member of resourceTypesInternalIPMap, which will belong to any resource eg. google_dataproc_cluster etc and each member will have path of its internal_ip_only as value. The code will evaluate the information by using this value and validate the said policy.
```
messages_ip_internal = {}

for resourceTypesInternalIPMap as key_address, _ {
	# Get all the instances on the basis of type
	allResources = plan.find_resources(key_address)
	for allResources as address, rc {
		message = null
		message = check_internal_ip(address, rc)

		if types.type_of(message) is not "null" {

			gen.create_sub_main_key_list(messages, messages_ip_internal, address)
			
			append(messages_ip_internal[address],message)
			append(messages[address],message)
		} 	
	}
}
```

#### Main Rule
The main function returns true/false as per value of GCP_INTERNAL_IP 
```
GCP_INTERNAL_IP = rule {
 	length(messages_ip_internal) is 0 
}

main = rule { GCP_INTERNAL_IP }
```
