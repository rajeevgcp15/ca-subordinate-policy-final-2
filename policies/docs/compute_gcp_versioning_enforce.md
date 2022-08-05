### compute_gcp_versioning_enforce.sentinel
```
GCP_GKE_RELEASECHANNEL: As per policy, enforce subscription to the STABLE  release channel when the label environment has the value prod.
GCP_GKE_DATAPLANEV2: As per policy, enforce the use of Dataplane-V2 for GKE network policies.
GCP_COMPOSER_ENV_VERSION: As per policy, enforce the value of image_version must prefixed with composer-2*
```

#### Imports
```
import "tfplan/v2" as tfplan
import "tfplan-functions" as plan
import "generic-functions" as gen
import "strings"
import "types"
```

#### Variables 
|Name|Description|
|----|-----|
|selected_node|It is being used locally to have information of node by passing the path.|
|messages| It is being used to hold the complete message of policies violation to show to the user.|

#### Maps
The below map is having entries of the GCP resources in key/value pair, those are required to be validated for "version enforce" policy check. Key will be name of the GCP terraform resource ("https://registry.terraform.io/providers/hashicorp/google/latest/docs") and its value will be again combination of key/value pair.   
The ```key``` entry within this block provides the attribute with complete path to evaluate & the ```value``` entry to compare its value with.  
The ```is_prefixed_check``` flag is used to specify if the attribute value needs to be checked for prefix only or for the exact value.   
In order to validate, just need to add corresponding entry of particular GCP terraform resource with the attribute path and its comparison value in the below map as given for google_container_cluster.

```
resourceTypesGCPVersionMap = {
	"google_container_cluster": [{
		"key":   "release_channel.0.channel",
		"value": "STABLE",
        "is_prefixed_check": false,
	},
	{
		"key":   "datapath_provider",
		"value": "ADVANCED_DATAPATH",
        "is_prefixed_check": false,	
	},],	
	"google_composer_environment": [{
		"key":   "config.0.software_config.0.image_version",
		"value":  "composer-2",
        "is_prefixed_check": true,
	},],
}
```

#### Methods
The below function is being used to validate the value of parameter ```release_channel.0.channel/datapath_provider/config.0.software_config.0.image_version``` As per the policy, its value needs to be matched and it cannot be empty/null. If the policy won't be validated successfully, it will generate appropriate message to show the users. This function will have below 2-parameters:

* Parameters

  |Name|Description|
  |----|-----|
  |address|The key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |rc|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock.|

  ```
  check_compute_version = func(address, rc){
	map_results = resourceTypesGCPVersionMap[rc.type]
	msg_list = null

	####------Iterating list of each resource of resourceTypesGCPVersionMap map----###
	for map_results as rec {

		selected_node = plan.evaluate_attribute(rc, rec.key)
		selected_node_result = rec.value		
		is_prefixed_check = rec.is_prefixed_check

		if types.type_of(selected_node) == "null" or types.type_of(selected_node) == "undefined" {
			if msg_list is null {
				msg_list = []
			}

			append(msg_list, "It does not have " + rec.key + " defined.")
		} else {
			####------Checking if need to have some prefix value----- 
			if is_prefixed_check is true {
					if not strings.has_prefix(selected_node, rec.value) {
						if msg_list is null {
						msg_list = []
					}
					append(msg_list, address +  " value of " + rec.key + " attribute should only start with " + rec.value + "*.")
				}
			} else {
				####------Checking if comparing with absolute value-----
				if not (plan.to_string(selected_node) == rec.value) {
					if msg_list is null {
						msg_list = []
					}
					append(msg_list, address +  " the value of " + plan.to_string(selected_node) + " can only be " + rec.value + ".")
				}
			}
		}
	}
	return msg_list
  }
  ```


#### Working Code
The below code will iterate each member of resourceTypesGCPVersionMap, which will belong to any resource eg. google_container_cluster etc and each member will have path of its respective nodes. The code will evaluate value and validate the said policy.
```
messages_compute_versions = {}

for resourceTypesGCPVersionMap as key_address, _ {
	# Get all the instances on the basis of type
	allResources = plan.find_resources(key_address)

	for allResources as address, rc {
		message = null

		####------using function to validate the respective values
		message = check_compute_version(address, rc)

		if types.type_of(message) is not "null" {

			gen.create_sub_main_key_list(messages, messages_compute_versions, address)

			append(messages_compute_versions[address], message)
			append(messages[address], message)
		}
	}
}
```

#### Main Rule
The main function returns true/false as per value of GCP_INTERNAL_IP 
```
GCP_GKE_RELEASECHANNEL = rule {
	length(messages_compute_versions) is 0
}

main = rule { GCP_GKE_RELEASECHANNEL }
```
