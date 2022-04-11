variable "vpcConfig" {
    default = {
        vpcName = "devops-edu"
        ipv4_cidr_block = "10.0.0.0/16"
    }
}


locals {
    subnets = csvdecode(file("subnet.csv"))

    credentials = jsondecode(file("../../cred.json"))
}