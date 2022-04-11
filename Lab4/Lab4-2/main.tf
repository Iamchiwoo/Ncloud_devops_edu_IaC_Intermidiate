# VPC 만들기
resource "ncloud_vpc" "vpc" {
    name = var.vpcConfig["vpcName"]
    ipv4_cidr_block = var.vpcConfig["ipv4_cidr_block"]
}

# NACL 만들기
resource "ncloud_network_acl" "nacl" {
    depends_on = [
        ncloud_vpc.vpc
    ]
    vpc_no = ncloud_vpc.vpc.id
    name = "${var.vpcConfig["vpcName"]}-nacl"
}

# 반복문 사용, 서브넷 만들기
resource "ncloud_subnet" "subnet_tx" {
    depends_on = [
        ncloud_vpc.vpc,
        ncloud_network_acl.nacl
    ]

    for_each = { for subnet in local.subnets : subnet.subnetName => subnet}

    vpc_no = ncloud_vpc.vpc.id
    network_acl_no = ncloud_network_acl.nacl.network_acl_no
    name = each.value.subnetName
    subnet = each.value.address
    zone = each.value.zone
    subnet_type = each.value.subnet_type
    usage_type = each.value.usage_type
}


# ACG 만들기
resource "ncloud_access_control_group" "devops_edu_acgs" {
    depends_on = [
        ncloud_subnet.subnet_tx
    ]

    for_each = { for acg in local.subnets : acg.subnetName => acg}
    
    vpc_no = ncloud_vpc.vpc.id
    name = "${each.value.subnetName}-acg"
    
}