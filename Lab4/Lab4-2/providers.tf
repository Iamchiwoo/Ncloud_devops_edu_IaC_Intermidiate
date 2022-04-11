terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {
  access_key  = local.credentials.accesId
  secret_key  = local.credentials.secret
  region      = local.credentials.region
  site        = local.credentials.site
  support_vpc = local.credentials.support_vpc
}