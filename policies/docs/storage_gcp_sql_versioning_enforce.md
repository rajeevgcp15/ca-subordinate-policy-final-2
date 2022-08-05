# storage_gcp_versioning_enforce
### Sentinel file "storage_gcp_versioning_enforce.sentinel" is having code to deploy the policies. In order to check the type of versioning is null or not null, We need to validate policy successfully.**

*This sentinel policies enforce usage of Number of versioned copies when versioning is enabled.
*These sentinel policies enforce Wells Fargo security principles
#### Variables :
messages: It is being used to hold the complete message of policies violation to show to the user.
#### Method :
*allBuckets: This is the function, being used to get the all available storage buckets regarding to "storage bucket".

*control statements: here we are looping and assigning the all the resourses into two parameters

   * Parameters
     | Name	| Description |
     |------|-------------|
     | address |	The key inside of resource_changes section for particular GCP Resource in tfplan mock
     | rc |	The value of address key inside of resource_changes section for particular GCP Resource in tfplan mock
* condition: if condition is comparing the type of versioning is not a null it will generate appropriate message to show the users.

#### Terraform version 
Terraform v1.0.7

#### sentinel versions 
Sentinel v0.18.4

modules to import:
------------------
* import "tfplan-functions"
* import "strings"
* import "types"
#### Testing a Policy
 sentinel test <sentinel file>
example : $sentinel apply storage_gcp_versioning_enforce.sentinel
