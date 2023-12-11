terraform {
  cloud {
    hostname = "tfe32.aws.munnep.com"
    organization = "test"

    workspaces {
      name = "test"
    }
  }
}

resource "null_resource" "name" {
  
}