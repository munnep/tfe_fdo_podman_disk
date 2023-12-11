# Network mirroring

The client machine also configures an nginx server that will host the latest aws and null provider that can be used with terraform as a network mirror. Create the environment as described in the main README.md of the repo. 

# How to
- Go into the directory `code_mirroring_test`
```
cd code_mirroring_test
```

- Edit the FQDN of your configured webserver in the file `terraformrc-configuration`
```
provider_installation {
  network_mirror {
    url = "https://patrick-tfe3-client.tf-support.hashicorpdemo.com/"
  }
}
```
- set your environment variable TF_CLI_CONFIG_FILE to the location of this file
```
export TF_CLI_CONFIG_FILE="./terraformrc-configuration"
```
- Have some code in main.tf file
```
resource "null" "test" {}
```
- Initialize the code using terraform init
```
terraform init
```
- The provider should now be downloaded from this website. You can verify this by setting `TF_LOG=TRACE` and do another initialization

```
2023-07-06T09:59:48.663+0200 [TRACE] HTTP client GET request to https://patrick-tfe3-client.tf-support.hashicorpdemo.com/registry.terraform.io/hashicorp/null/terraform-provider-null_3.2.1_darwin_amd64.zip
```