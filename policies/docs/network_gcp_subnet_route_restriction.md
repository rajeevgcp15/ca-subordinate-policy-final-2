# network_gcp_subnet_route_restriction
### Sentinel file "network_gcp_subnet_route_restriction.sentinel" is having code to deploy the policies. In order to validate the settings of auto_create_subnetworks mode , We need to validate policy successfully.**
* The purpose of this policy is validate the settings of auto_create_subnetworks mode.
### Variables :
* selected_node : it is being used to validate the type of selected_node is null or undefined.
* messages: It is being used to hold the complete message of policies violation to show to the user.

#### methods:

* Following function is being used to validate the settings of auto_create_subnetworks mode
```
check_auto_create_subnets = func(address, rc) {

	key = "auto_create_subnetworks"
	selected_node = plan.evaluate_attribute(rc, key)

	if selected_node {
		return plan.to_string(address) + " no auto subnet creation mode is allowed, please mark its value false to have custom mode."
	} else {
		return null
	}
}
```

* Following function is being used to validate the settings of delete_default_routes_on_create mode
```
check_delate_default_routes_on_create = func(address, rc) {

	key = "delete_default_routes_on_create"
	selected_node = plan.evaluate_attribute(rc, key)

	if selected_node {
		return null
	} else {
		return plan.to_string(address) + " no default routes are allowed, please mark its value true."
	}
}
```

* validating auto create subnets mode
```
messages_auto_create_subnets = {}

for allResources as address, rc {
	message = null
	message = check_auto_create_subnets(address, rc)

	if types.type_of(message) is not "null" {

		gen.create_sub_main_key_list(messages, messages_auto_create_subnets, address)

		append(messages_auto_create_subnets[address], message)
		append(messages[address], message)
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
 $ sentinel test network_gcp_subnet_route_restriction.sentinel 
