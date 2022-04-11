## VPC 만들기
ncloud vpc createVpc `
	--regionCode KR `
	--vpcName devops-edu `
	--ipv4CidrBlock 10.0.0.0/16

	

## VPC 정보 불러오기
$vpcList = ((ncloud vpc getVpcList --vpcName devops-edu) | ConvertFrom-Json).getVpcListResponse.vpcList
$eduVpc = $vpcList | Where-Object {$_.vpcName -eq "devops-edu" }
$eduVpcNo = $eduVpc.vpcNo

$eduVpc
$eduVpcNo


## ACL 정보 불러오기
$eduNacl = ((ncloud vpc getNetworkAclList --vpcNo $eduVpcNo) | ConvertFrom-Json).getNetworkAclListResponse.networkAclList
$eduNaclNo = $eduNacl[0].networkAclNo

$eduNacl
$eduNaclNo


## 서브넷 만들기
ncloud vpc createSubnet --regionCode KR --zoneCode KR-1 `
	    --vpcNo $eduVpcNo --subnetName devops-edu-t1 `
	    --subnet 10.0.10.0/24 --networkAclNo $eduNaclNo `
	    --subnetTypeCode PUBLIC


ncloud vpc createSubnet --regionCode KR --zoneCode KR-1 `
	    --vpcNo $eduVpcNo --subnetName devops-edu-t2 `
	    --subnet 10.0.20.0/24 --networkAclNo $eduNaclNo `
	    --subnetTypeCode PRIVATE


ncloud vpc createSubnet --regionCode KR --zoneCode KR-1 `
	    --vpcNo $eduVpcNo --subnetName devops-edu-t3 `
	    --subnet 10.0.30.0/24 --networkAclNo $eduNaclNo `
	    --subnetTypeCode PRIVATE