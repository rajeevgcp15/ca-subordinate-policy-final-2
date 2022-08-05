### network_gcp_ssl_enforce.sentinel
```
GCP_SSL_ENFORCE: As per policy, only https access will be allowed.
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
|messages|It is being used to hold the complete message of policies violation to show to the user.|

#### Maps
The below map is having entries of the GCP resources in key/value pair, those are required to be validated for SSL enforcement policy. Key will be name of the GCP terraform resource ("https://registry.terraform.io/providers/hashicorp/google/latest/docs") and its value will be again combination of key/value pair. Here now key will be ```key``` only and value will be the path of enable_http_port_access node. Since this is the generic one and can validate enable_http_port_access associated with any GCP resource. In order to validate, just need to add corresponding entry of particular GCP terraform resource with the path of its enable_http_port_access in the below map as given for google_dataproc_cluster or example_rsc.
```
resourceTypesSSLEnforceMap = {	
	"google_dataproc_cluster": {
		"key":   	"cluster_config.0.endpoint_config.0.enable_http_port_access",
	},
	"example_rsc": {
	     "key": "someroot.enable_http_port_access",
	},
}
```

#### Methods
The below function is being used to validate the value of parameter ```enable_http_port_access```. As per the policy, its value can not be true. If the policy will not be validated successfully, it will generate appropriate message to show the users. This function will have below 2-parameters:

* Parameters

  |Name|Description|
  |----|-----|
  |address|The key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |rc|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock.|

  ```
  check_endpoint_config = func(address, rc) {

	key = resourceTypesSSLEnforceMap[rc.type]["key"]
	selected_node = plan.evaluate_attribute(rc, key)
	
	if  selected_node {
		return "Http port's access needs to be disabled for the " + plan.to_string(address) + " services, please set value false to make it disabled"
	} else {
		return null
	}
  }
  ```

#### Working Code
The below code will iterate each member of resourceTypesSSLEnforceMap, which will belong to any resource eg. google_dataproc_cluster etc and each member will have path of its enable_http_port_access as value. The code will evaluate the enable_http_port_access's information by using this value and validate the said policy.
```
messages_http = {}

for resourceTypesSSLEnforceMap as key_address, _ {
	
	# Get all the instances on the basis of type
	allResources = plan.find_resources(key_address)
	
	for allResources as address, rc {
		message = null
		message = check_endpoint_config(address, rc)

		if types.type_of(message) is not "null"{
			
			gen.create_sub_main_key_list( messages, messages_http, address)

			append(messages_http[address],message)
			append(messages[address],message)

		}
	}
}

GCP_SSL_ENFORCE = rule {
	length(messages_http) is 0
}

```

The below code is for Certificate Authority service to "Ensure at least one issuance policy is defined" for property "google_privateca_ca_pool.issuance_policy" and to "Ensure issuance policy is defined using CEL" for property "google_privateca_ca_pool.issuance_policy.identity_constraints.cel_expression.expression".

```

allPrivatecaCAPoolInstances = plan.find_resources("google_privateca_ca_pool")

# Resource google_privateca_ca_pool
# Policy 1 - google_privateca_ca_pool.issuance_policy

violations_ca_pool_issuance_policy = {}
for allPrivatecaCAPoolInstances as address, rc {
	ca_pool_issuance_policy = plan.evaluate_attribute(rc, "issuance_policy")
    if types.type_of(ca_pool_issuance_policy) is "undefined" or types.type_of(ca_pool_issuance_policy) is "null" {
		violations_ca_pool_issuance_policy[address] = rc
		print("The value for ca_pool_issuance_policy in Resource " + address + " can't be null or undefined")	
	}else {
		if length(ca_pool_issuance_policy) == 0 {
			violations_ca_pool_issuance_policy[address] = rc
			print("Length of ca_pool_issuance_policy in Resource " + address + " must be greater then zero")		
		}
    }
}

GCP_CAS_ISSUANCEPOLICY = rule { length(violations_ca_pool_issuance_policy) is 0 }

# Policy 2 - google_privateca_ca_pool.issuance_policy.identity_constraints.cel_expression.expression

violations_cel_expression = {}
for allPrivatecaCAPoolInstances as address, rc {
	ca_pool_cel_expression = plan.evaluate_attribute(rc, "issuance_policy.0.identity_constraints.0.cel_expression.0.expression")
    if types.type_of(ca_pool_cel_expression) is "undefined" or types.type_of(ca_pool_cel_expression) is "null" {
		violations_cel_expression[address] = rc
		print("The value for ca_pool_cel_expression in Resource " + address + " can't be null or undefined")	
	}else {
		if length(ca_pool_cel_expression) == 0 {
			violations_cel_expression[address] = rc
			print("Length of ca_pool_cel_expression in Resource " + address + " must be greater then zero")		
		}
    }
}

GCP_CAS_ISSUANCEPOLICYCEL = rule { length(violations_cel_expression) is 0 }
```


#### Main Rule
The main function returns true/false as per values of GCP_SSL_ENFORCE, GCP_CAS_ISSUANCEPOLICY & GCP_CAS_ISSUANCEPOLICYCEL 

```

main = rule { GCP_CAS_ISSUANCEPOLICY and GCP_CAS_ISSUANCEPOLICYCEL and GCP_SSL_ENFORCE }

```
