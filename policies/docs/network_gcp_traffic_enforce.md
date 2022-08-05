# network_gcp_traffic_enforce

### Sentinel file "network_gcp_traffic_enforce.sentinel" is having code to deploy the policies. In order to validate the ingress, VPC Connector and VPC Connector egress settings as per the GCP resource's requirement, We need to validate policy successfully.**
* the purpose of this policy is to validate the ingress, VPC Connector and VPC Connector egress settings as per the GCP resource's requirement.
#### Variables :
* selected_node : it is being used to validate the type of selected_node is null or undefined.
* messages: It is being used to hold the complete message of policies violation to show to the user.
#### methods:

* Following function is being used to validate the ingress, VPC Connector and VPC Connector egress settings as per the GCP resource's requirement
//address is the key and rc is the value of resource_changes in the mock of tfplan-v2 file

```
check_ingress_settings = func(address, rc) {

	key = resourceTypesTrafficEnforceMap[rc.type]["key_ingress"]
	selected_node = plan.evaluate_attribute(rc, key)

	if types.type_of(selected_node) is not "undefined" and selected_node != "ALLOW_INTERNAL_ONLY" {
		return "Requests from private VPC are allowed only for " + plan.to_string(address) + " services, please set value ALLOW_INTERNAL_ONLY"
	} else {
		return null
	}
}

check_vpc_connector = func(address, rc) {

	key = resourceTypesTrafficEnforceMap[rc.type]["key_vpc"]
	selected_node = plan.evaluate_attribute(rc, key)

	if types.type_of(selected_node) is "null" or types.type_of(selected_node) is "undefined" {

		selected_node = plan.evaluate_attribute(rc.change.after_unknown, key)

		if types.type_of(selected_node) is not "null" and selected_node is true {
			return null
		} else {
			return plan.to_string(address) + " does not have " + key + " defined"
		}
	} else {
		connector_name = plan.to_string(selected_node)

		if connector_name is "" {
			return plan.to_string(address) + " does not have " + key + " defined"
		} else {
			contr_arr = strings.split(connector_name, "/")
			contr_arr_p = strings.split(connector_name, "projects")
			contr_arr_l = strings.split(connector_name, "locations")
			contr_arr_c = strings.split(connector_name, "connectors")

			if length(contr_arr) > 5 and length(contr_arr_p) > 1 and length(contr_arr_l) > 1 and length(contr_arr_c) > 1 {
				return null
			} else {
				return "Please provide valid VPC Connector with fully-qualified URI. The format needs to be like projects/*/locations/*/connectors/*"
			}
		}
	}
}

check_vpc_connector_egress = func(address, rc) {

	key_egress = resourceTypesTrafficEnforceMap[rc.type]["key_egress"]
	selected_node = plan.evaluate_attribute(rc, key_egress)

	if types.type_of(selected_node) is "null" or types.type_of(selected_node) is "undefined" {
		return plan.to_string(address) + " does not have " + key_egress + " defined"
	} else {
		if selected_node is "ALL_TRAFFIC" {
			return null
		} else {
			return plan.to_string(address) + ": " + key_egress + " Route all egress traffic to the VPC connector assigned, please assign its value to ALL_TRAFFIC"
		}
	}
}
```
* Validate VPC Connector, egress settings

```
for resourceTypesTrafficEnforceMap as key_address, _ {

	# Get all the instances on the basis of type
	allResources = plan.find_resources(key_address)

	for allResources as address, rc {
		message = null
		message_sub = check_vpc_connector(address, rc)

		if message_sub is not null {
			message = plan.to_string(message_sub)
		}

		message_sub = check_vpc_connector_egress(address, rc)

		if message_sub is not null {
			if message is not null {
				message = message + plan.to_string(message_sub)
			} else {
				message = plan.to_string(message_sub)
			}
		}

		if types.type_of(message) is not "null" {

			gen.create_sub_main_key_list(messages, messages_vpc_connector, address)

			append(messages_vpc_connector[address], message)
			append(messages[address], message)
		}
	}
}

```


   * Parameters
      |Name|Description|
      |----|-----|
      |address|The key inside of resource_changes section for particular GCP Resource in tfplan mock|
      |rc|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock|


#### Terraform version 
Terraform v1.0.7

#### sentinel versions 
Sentinel v0.18.4 

#### modules to import:
* import "strings"
* import "types"
* import "tfplan-functions" as plan
* import "generic-functions" as gen

#### Testing a Policy
     sentinel test <sentinel file> 
example : 
 $ sentinel test network_gcp_traffic_enforce.sentinel 
