function createSignedSignature(
    [string] $method,      # GET, PUT, POST, DELETE
    [string] $url,         # path+query
    [string] $accessKey,   # access key id
    [string] $secretKey    # access key value
)
{  
    $verb = $method.ToUpperInvariant()
    $timeStamp = [int](Get-Date -UFormat %s) * 1000

    $stringToSign = $verb + " " + $url + "`n" +
                    [string]$timeStamp + "`n" +
                    $accessKey

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($secretKey)
    $signature = [Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign)))

    return @{
        "x-ncp-apigw-timestamp" = $timeStamp;
        "x-ncp-iam-access-key" = $accessKey;
        "x-ncp-apigw-signature-v2" = $signature;
    }
}

# VPC 정보 불러오기
$cred = Get-Content -Raw -Path "../cred.json" | ConvertFrom-Json
$resource = "/vpc/v2/getVpcList?vpcName=devops-edu&responseFormatType=json"
$url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
$signedHeader = createSignedSignature `
                        -method "GET" `
                        -url $resource `
                        -accessKey $cred.accesId `
                        -secretKey $cred.secret
$devopsEduVpc = (Invoke-RestMethod -Method Get `
                -Uri $url `
                -Headers $signedHeader).getVpcListResponse.vpcList
                | Where-Object {$_.vpcName -eq "devops-edu"}

# 불러온 VPC 정보에서 VPCNO 추출            
$devopsEduVpcNo = $devopsEduVpc[0].vpcNo

# NACL 정보 불러오기
$resource = "/vpc/v2/getNetworkAclList?vpcNo={0}&responseFormatType=json" -f $devopsEduVpcNo
$url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
$signedHeader = createSignedSignature `
                        -method "GET" `
                        -url $resource `
                        -accessKey $cred.accesId `
                        -secretKey $cred.secret
$devopsEduVpcNacl = (Invoke-RestMethod -Method Get `
                                -Uri $url `
                                -Headers $signedHeader).getNetworkAclListResponse.networkAclList

# 불러온 NACL 정보에서 NACLNO 추출
$devopsEduVpcNaclNo = $devopsEduVpcNacl[0].networkAclNo

# 서브넷 만들기
$resource = "/vpc/v2/createSubnet?{0}&{1}&{2}&{3}&{4}&{5}" -f
                                                "zoneCode=KR-1",
                                                "vpcNo=$devopsEduVpcNo",
                                                "subnetName=devops-edu-dev",
                                                "subnet=10.0.100.0/24",
                                                "networkAclNo=$devopsEduVpcNaclNo",
                                                "subnetTypeCode=PUBLIC"
$url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
$signedHeader = createSignedSignature `
                        -method "GET" `
                        -url $resource `
                        -accessKey $cred.accesId `
                        -secretKey $cred.secret

$subnet = Invoke-RestMethod -Method Get `
                           -Uri $url `
                           -Headers $signedHeader

# 요청 상태 확인                      
$subnet.createSubnetResponse


## 서브넷 조회
$cred = Get-Content -Raw -Path "../cred.json" | ConvertFrom-Json
$resource = "/vpc/v2/getSubnetList?{0}&{1}" -f "vpcNo=$devopsEduVpcNo", "responseFormatType=json"
$url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
$signedHeader = createSignedSignature `
                        -method "GET" `
                        -url $resource `
                        -accessKey $cred.accesId `
                        -secretKey $cred.secret

$subnetList = (Invoke-RestMethod -Method Get `
                                 -Uri $url `
                                 -Headers $signedHeader).
                                 getSubnetListResponse.
                                 subnetList
# 서브넷 목록 확인                        
$subnetList | Format-Table

# 반복문을 사용하여 서브넷 삭제
foreach($subnet in $subnetList) {
    $subnetNo = $subnet.subnetNo
    $cred = Get-Content -Raw -Path "../cred.json" | ConvertFrom-Json
    $resource = "/vpc/v2/deleteSubnet?{0}" -f "subnetNo=${subnetNo}", "responseFormatType=json"
    $url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
    $signedHeader = createSignedSignature `
                            -method "GET" `
                            -url $resource `
                            -accessKey $cred.accesId `
                            -secretKey $cred.secret

    Invoke-RestMethod -Method Get `
                      -Uri $url `
                      -Headers $signedHeader
    
    # 1초 대기
    Start-Sleep -Seconds 1
}


# VPC 삭제
$resource = "/vpc/v2/deleteVpc?{0}" -f "vpcNo=$devopsEduVpcNo"
$url = "{0}{1}" -f "https://ncloud.apigw.ntruss.com", $resource
$signedHeader = createSignedSignature `
                        -method "GET" `
                        -url $resource `
                        -accessKey $cred.accesId `
                        -secretKey $cred.secret

Invoke-RestMethod -Method Get `
                  -Uri $url `
                  -Headers $signedHeader