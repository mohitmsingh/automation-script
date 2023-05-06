
###################################################################################
$EncryptedData = "76492d1116743f0423413b16050a5345MgB8AFQAOQBYAE4ATwBLAEMANQBkADUAWQBTAHMAWQBvAHIAMABtAGQAbQBMAGcAPQA9AHwAMwAyADgAYQBiADAAOQBjADMAMQA4ADgAYQA0AGQAYQAzAGYAYQBlADIANwBiAGIAMABjADYANgAyADcANAAzADQAZgBmADYANAA3ADcANgBmADgAOAAyADAAZgA5ADYANgAxAGYAYQAwADQAYQA2ADMANABiADkAMwBlADgAOABlADUAOABhADcAYwBhAGYAZQA4AGUAYwA0ADEAYgBmAGYANABmADQAYQA1ADUANwAwADQAZAA3ADMAZABmAGYAOAAyADMAMwAxADcANgAwADQAYgBmAGMAMQA3AGUAZgAwADEAMwBiADIAYQBlADMAOQAwADQANgAyAGEAMAA5ADIANQA2AGYAYwAwADIAZQBiADQANQA3AGIANwAxADkANAAwADYANQA2ADAAYwBiAGYAMwBhADcANgA0ADYAMgBmAGIAZgBmADIANgA2ADUAYgAxADgAZAA4ADMAZQBhADcAZQAzAGYAYgBlADYAOQA0AGUAMgBjAGIAZQBjAGIA"
[Byte[]]$key = (1..32)
$auth_token = ConvertTo-SecureString $EncryptedData -key $key
$auth_token = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($auth_token))
###################################################################################

Write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
Write-host ""
$app = Read-Host "Please enter App Name [XXX]"
Write-host ""
Write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

###################################################################################

$csvPath = "D:\Project-AIS\AutomationPowershell\Update-AISEnvVariable_1v\variables_$app.csv"


$csv = Import-CSV $csvPath | ForEach-Object {

    $repo_name = $($_.repo_name)
    $env_name = $($_.env_name)
    $name = $($_.env_var_name)
    $value = $($_.env_var_value)
    #$auth_token = "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"
    $head = @{"Accept"="application/vnd.github+json";"Authorization"="Bearer $auth_token";"X-GitHub-Api-Version"="2022-11-28"}
    
    $response = Invoke-WebRequest -Uri "https://api.github.com/repos/$repo_name" -Headers $head
    $repo = $response | ConvertFrom-Json
    $repo_id = $($repo.id)

$body = @"
{
    "name": "$name",
    "value": "$value"
}
"@

    try {
            if((Invoke-WebRequest -Uri "https://api.github.com/repositories/$repo_id/environments/$env_name/variables/$name" -Headers $head -UseBasicParsing -DisableKeepAlive).StatusCode -eq 200 ){
                #Update##############################################################
                Invoke-WebRequest -Uri "https://api.github.com/repositories/$repo_id/environments/$env_name/variables/$name" -Headers $head -Body $body -Method Patch
                Write-host "[Updated]|[$app][$env_name]|[$name]=[$value]"
                #####################################################################
            }
            }
  catch {
            if( $_.Exception.Response.StatusCode.Value__ -eq 404 ) 
            {
                #Create##############################################################
                Invoke-WebRequest -Uri "https://api.github.com/repositories/$repo_id/environments/$env_name/variables" -Headers $head -Body $body -Method Post
                Write-host "[Created]|[$app][$env_name]|[$name]=[$value]"
                #####################################################################
            }
        }

} 

Write-host ""
$app = Read-Host "Press any key to exit."
Write-host ""
Write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
