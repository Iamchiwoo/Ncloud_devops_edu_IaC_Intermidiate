resource "ncloud_vpc" "vpc" {
  name            = var.vpcConfig["vpcName"]
  ipv4_cidr_block = var.vpcConfig["ipv4_cidr_block"]
}

# peer vpc 정보를 불러옵니다.
data "ncloud_vpc" "peer_vpc" {
  name = var.peer_vpc
}

# peer subnet 정보를 불러옵니다.
data "ncloud_subnet" "peer_subnet" {
  vpc_no = data.ncloud_vpc.peer_vpc.id
  filter {
    name   = "name"
    values = ["${var.peer_vpc}"]
  }
}

# NACL 생성
resource "ncloud_network_acl" "nacl" {
  depends_on = [
    ncloud_vpc.vpc
  ]
  vpc_no = ncloud_vpc.vpc.id
  name   = "${var.vpcConfig["vpcName"]}-nacl"
}


# devops-edu vpc의 서브넷 생성
resource "ncloud_subnet" "subnet_t1" {
  depends_on = [
    ncloud_vpc.vpc,
    ncloud_network_acl.nacl
  ]
  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.nacl.network_acl_no
  name           = var.subnet_t1["name"]
  subnet         = var.subnet_t1["address"]
  zone           = var.subnet_t1["zone"]
  subnet_type    = var.subnet_t1["subnet_type"]
  usage_type     = var.subnet_t1["usage_type"]
}

resource "ncloud_subnet" "subnet_t2" {
  depends_on = [
    ncloud_vpc.vpc,
    ncloud_network_acl.nacl
  ]
  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.nacl.network_acl_no
  name           = var.subnet_t2["name"]
  subnet         = var.subnet_t2["address"]
  zone           = var.subnet_t2["zone"]
  subnet_type    = var.subnet_t2["subnet_type"]
  usage_type     = var.subnet_t2["usage_type"]
}

resource "ncloud_subnet" "subnet_t3" {
  depends_on = [
    ncloud_vpc.vpc,
    ncloud_network_acl.nacl
  ]
  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.nacl.network_acl_no
  name           = var.subnet_t3["name"]
  subnet         = var.subnet_t3["address"]
  zone           = var.subnet_t3["zone"]
  subnet_type    = var.subnet_t3["subnet_type"]
  usage_type     = var.subnet_t3["usage_type"]
}


resource "ncloud_subnet" "loadBalancer_t1" {
  depends_on = [
    ncloud_vpc.vpc,
    ncloud_network_acl.nacl
  ]
  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.nacl.network_acl_no
  name           = var.loadBalancer_t1["name"]
  subnet         = var.loadBalancer_t1["address"]
  zone           = var.loadBalancer_t1["zone"]
  subnet_type    = var.loadBalancer_t1["subnet_type"]
  usage_type     = var.loadBalancer_t1["usage_type"]
}

resource "ncloud_subnet" "loadBalancer_t2" {
  depends_on = [
    ncloud_vpc.vpc,
    ncloud_network_acl.nacl
  ]
  vpc_no         = ncloud_vpc.vpc.id
  network_acl_no = ncloud_network_acl.nacl.network_acl_no
  name           = var.loadBalancer_t2["name"]
  subnet         = var.loadBalancer_t2["address"]
  zone           = var.loadBalancer_t2["zone"]
  subnet_type    = var.loadBalancer_t2["subnet_type"]
  usage_type     = var.loadBalancer_t2["usage_type"]
}



resource "ncloud_vpc_peering" "vpc_peering_devopsedu" {
  depends_on = [
    ncloud_vpc.vpc
  ]
  name          = "devops-edu--to--devops-edu-iac"
  source_vpc_no = ncloud_vpc.vpc.id
  target_vpc_no = data.ncloud_vpc.peer_vpc.id
}
resource "ncloud_vpc_peering" "vpc_peering_devopseduiac" {
  depends_on = [
    ncloud_vpc.vpc
  ]
  name          = "devops-edu-iac--to--devops-edu"
  source_vpc_no = data.ncloud_vpc.peer_vpc.id
  target_vpc_no = ncloud_vpc.vpc.id
}



## devops-edu Public 라우팅 테이블 생성
resource "ncloud_route_table" "devops_edu_public" {
  depends_on = [
    ncloud_vpc_peering.vpc_peering_devopsedu,
    ncloud_vpc_peering.vpc_peering_devopseduiac
  ]
  vpc_no                = ncloud_vpc.vpc.id
  name                  = "${var.devops_edu_route_table["devops-edu"]}-public"
  supported_subnet_type = "PUBLIC"
}
resource "ncloud_route_table_association" "devops_edu_association" {
  depends_on = [
    ncloud_route_table.devops_edu_public
  ]
  route_table_no = ncloud_route_table.devops_edu_public.id
  subnet_no      = ncloud_subnet.subnet_t1.id
}

## devops-edu Private 라우팅 테이블 생성
resource "ncloud_route_table" "devops_edu_private" {
  depends_on = [
    ncloud_vpc_peering.vpc_peering_devopsedu,
    ncloud_vpc_peering.vpc_peering_devopseduiac
  ]
  vpc_no                = ncloud_vpc.vpc.id
  name                  = "${var.devops_edu_route_table["devops-edu"]}-private"
  supported_subnet_type = "PRIVATE"
}
# private 서브넷 devops-edu-t2 와 연결
resource "ncloud_route_table_association" "devops_edu_association2" {
  depends_on = [
    ncloud_route_table.devops_edu_private
  ]
  route_table_no = ncloud_route_table.devops_edu_private.id
  subnet_no      = ncloud_subnet.subnet_t2.id
}
# private 서브넷 devops-edu-t3 와 연결
resource "ncloud_route_table_association" "devops_edu_association3" {
  depends_on = [
    ncloud_route_table.devops_edu_private
  ]
  route_table_no = ncloud_route_table.devops_edu_private.id
  subnet_no      = ncloud_subnet.subnet_t3.id
}


# devops-edu-t1 > VPCPEERING to devops-edu-iac 172.16.0.0/24
resource "ncloud_route" "devops_edu__to__devops_edu_Public" {
  depends_on = [
    ncloud_route_table_association.devops_edu_association
  ]
  route_table_no         = ncloud_route_table.devops_edu_public.id
  destination_cidr_block = data.ncloud_subnet.peer_subnet.subnet
  target_type            = "VPCPEERING"
  target_name            = ncloud_vpc_peering.vpc_peering_devopsedu.name
  target_no              = ncloud_vpc_peering.vpc_peering_devopsedu.id
}

# devops-edu-t2 > VPCPEERING to devops-edu-iac 172.16.0.0/24
# devops-edu-t3 > VPCPEERING to devops-edu-iac 172.16.0.0/24
resource "ncloud_route" "devops_edu__to__devops_edu_Private" {
  depends_on = [
    ncloud_route_table_association.devops_edu_association2,
    ncloud_route_table_association.devops_edu_association3
  ]
  route_table_no         = ncloud_route_table.devops_edu_private.id
  destination_cidr_block = data.ncloud_subnet.peer_subnet.subnet
  target_type            = "VPCPEERING"
  target_name            = ncloud_vpc_peering.vpc_peering_devopsedu.name
  target_no              = ncloud_vpc_peering.vpc_peering_devopsedu.id
}



# devope-edu-iac Public 의 라우팅 테이블 생성
resource "ncloud_route_table" "devops_edu_iac_public" {
  depends_on = [
    ncloud_vpc_peering.vpc_peering_devopsedu,
    ncloud_vpc_peering.vpc_peering_devopseduiac
  ]
  vpc_no                = data.ncloud_vpc.peer_vpc.id
  name                  = "${var.devops_edu_route_table["devops-edu-iac"]}-public"
  supported_subnet_type = "PUBLIC"
}

# devops-edu-iac와 연결
resource "ncloud_route_table_association" "devops_edu_iac_association" {
  depends_on = [
    ncloud_route_table.devops_edu_iac_public
  ]
  route_table_no = ncloud_route_table.devops_edu_iac_public.id
  subnet_no      = data.ncloud_subnet.peer_subnet.subnet_no
}

# devops-edu-iac > VPCPEERING to devops-edu 10.0.0.0/16
resource "ncloud_route" "devops_edu_Public__to__devops_edu" {
  depends_on = [
    ncloud_route_table_association.devops_edu_iac_association
  ]
  route_table_no         = ncloud_route_table.devops_edu_iac_public.id
  destination_cidr_block = ncloud_vpc.vpc.ipv4_cidr_block
  target_type            = "VPCPEERING"
  target_name            = ncloud_vpc_peering.vpc_peering_devopseduiac.name
  target_no              = ncloud_vpc_peering.vpc_peering_devopseduiac.id
}