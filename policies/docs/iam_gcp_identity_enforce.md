### iam_gcp_identity_enforce.sentinel
```
GCP_GKE_WORLOADIDENT: As per policy, enforce enabling Workload Identity & Default UI role for Cloud Composer
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
The below map is having entries of the GCP resources in key/value pair, those are required to be validated for identity related policy. Key will be name of the GCP terraform resource ("https://registry.terraform.io/providers/hashicorp/google/latest/docs") and its value will be again combination of key/value pair. Here now key will be ```key``` only and value will be the path of the attribute which needs to be checked. Since this is the generic one and can validate attribute associated with any google resource. In order to validate, just need to add corresponding entry of particular GCP terraform resource with the attribute path in the below map as given for google_container_cluster.
The ```is_project_id``` flag is used to determine, if Project_ID needs to be prefixed to the value key

```
resourceTypesGCPIdentityMap = {
	"google_container_cluster": {
		"key":   "workload_identity_config.0.workload_pool",
		"value": ".svc.id.goog",
		"is_project_id": true,
	},
	"google_composer_environment": {
		"key":   "config.0.software_config.0.airflow_config_overrides.webserver-rbac_user_registration_role",
		"value":  "Viewer",
		"is_project_id": false,
	},
}
```

#### Methods
The first below function is being used to fetch the values of Project Id from States of tfplan file and second one used to compare the values with said one. The second function will have below 4-parameters:

* Parameters

  |Name|Description|
  |----|-----|
  |address|The key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |rc|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |key|The key inside of resource_changes section for particular GCP Resource in tfplan mock.|
  |value|The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock.|

```
//*******************Fetching value of Project Id from States of tfplan file**************
get_workload_project_identity_config = func(sub_value){
    workload_pool_var = ""

    datasource = tfplan.raw.prior_state.values.root_module.resources
    is_null_datasource = rule { types.type_of(datasource) == "undefined" }
    
    if not is_null_datasource {
        projects = filter tfplan.raw.prior_state.values.root_module.resources as _, rc {
            rc.type is "google_project"
        }

        project_id = ""
        for projects as address, rc {
            project_id = plan.evaluate_attribute(rc, "values.project_id")
        }

        workload_pool_var = plan.to_string(project_id) + sub_value
    }
    return workload_pool_var
}

//*******************Comparing values with the given one**************
check_gcp_identity = func(address, rc, key, value) {
    message = null
    workload_pool = plan.evaluate_attribute(rc, key)

    if types.type_of(workload_pool) == "null" or types.type_of(workload_pool) == "undefined" {
        message = address + "the value of  " + key + " can't be null or undefined"
    } else {
        if not (workload_pool == value) {
           message = address + "the value of  " + key + " can only be " + value + "."
        }
	}

    return message
}
```

#### Working Code
The below code will iterate each instance of type google_container_cluster and each will have path of its release_channel as value. The code will evaluate the workload_identity_config's information by using this value and validate the said policy.
```
messages_gi = {}
for resourceTypesGCPIdentityMap as key_address, rtg {

    key = rtg.key
    sub_value = rtg.value
    final_value = ""
    is_project_id = rtg.is_project_id

    if is_project_id is true {
        final_value = get_workload_project_identity_config(sub_value)
    } else {
        final_value = sub_value
    }

    if is_project_id is true and final_value is "" {
        message = "For resource: " + key_address + ", please define data source for resource type: google_project"
        gen.create_sub_main_key_list(messages, messages_gi, key_address)
        append(messages_gi[key_address], message)
        append(messages[key_address], message)

    } else {
        # Get all the instances on the basis of type
        allResources = plan.find_resources(key_address)  

        for allResources as address, rc {
            message = null
            message = check_gcp_identity(address, rc, key, final_value)
            if types.type_of(message) is not "null" {

                gen.create_sub_main_key_list(messages, messages_gi, address)

                append(messages_gi[address], message)
                append(messages[address], message)
            }
        }
    }
}
```

#### Main Rule
The main function returns true/false as per value of GCP_GKE_WORLOADIDENT
```
GCP_GKE_WORLOADIDENT = rule {
	length(messages_gi) is 0
}

main = rule { GCP_GKE_WORLOADIDENT }
```
