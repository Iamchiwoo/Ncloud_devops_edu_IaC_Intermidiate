variable "vpcConfig" {
  default = {
    vpcName         = "devops-edu"
    ipv4_cidr_block = "10.0.0.0/16"
  }
}

variable "peer_vpc" {
  default = "<your-vpc-name>"
}


variable "subnet_t1" {
  default = {
    name        = "devops-edu-t1"
    address     = "10.0.10.0/24"
    zone        = "KR-1"
    subnet_type = "PUBLIC"
    usage_type  = "GEN"
  }
}

variable "subnet_t2" {
  default = {
    name        = "devops-edu-t2"
    address     = "10.0.20.0/24"
    zone        = "KR-1"
    subnet_type = "PRIVATE"
    usage_type  = "GEN"
  }
}

variable "subnet_t3" {
  default = {
    name        = "devops-edu-t3"
    address     = "10.0.30.0/24"
    zone        = "KR-1"
    subnet_type = "PRIVATE"
    usage_type  = "GEN"
  }
}


variable "loadBalancer_t1" {
  default = {
    name        = "devops-edu-lb-t1"
    address     = "10.0.11.0/24"
    zone        = "KR-1"
    subnet_type = "PRIVATE"
    usage_type  = "LOADB"
  }
}

variable "loadBalancer_t2" {
  default = {
    name        = "devops-edu-lb-t2"
    address     = "10.0.21.0/24"
    zone        = "KR-1"
    subnet_type = "PRIVATE"
    usage_type  = "LOADB"
  }
}

variable "devops_edu_route_table" {
  default = {
    devops-edu     = "devops-edu-route"
    devops-edu-iac = "devops-edu-iac-route"
  }
}


locals {
    credentials = jsondecode(file("../../cred.json"))
}