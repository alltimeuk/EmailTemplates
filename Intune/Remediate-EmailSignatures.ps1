<#
.SYNOPSIS
    PowerShell script to remediate an pre/non existing Email Signatures; from Set-OutlookSignatures script.

.EXAMPLE
    .\Remediate-EmailSignatures.ps1

.DESCRIPTION
    This PowerShell script is deployed as a remediation script using Microsoft Intune remediations.

.LINK
    https://github.com/alltimeuk/EmailTemplates/blob/main/Intune/Remediate-EmailSignatures.ps1

.LINK
    https://learn.microsoft.com/en-us/mem/intune/fundamentals/remediations

.NOTES
    Version:        1.0
    Creation Date:  2023-11-07
    Last Updated:   2023-11-07
    Author:         Simon Jackson @ Alltime Technologies Ltd
    Organization:   Alltime Technologies Ltd
    Contact:        sjackson0109 @ jacksonfamily . me

#>
# Variables for Download and Extract
$githubProductOrg = "Set-OutlookSignatures"
$githubProductRepo = "Set-OutlookSignatures"
$githubTemplateOrg = "alltimeuk"
$githubTemplateRepo = "EmailTemplates"

# Variables for customers to configure the product with
$graphOnly = "true"
$SetOofMsg = "false"
$CreateRtfSignatures = "true"
$CreateTxtSignatures = "true"
$DisableRoamingSignatures = "true"
$MirrorLocalSignaturesToCloud = "true"

# Init
#New-Item -Name "temp" -path $env:localappdata -ItemType Directory -ErrorAction SilentlyContinue
$temp = "$($env:localappdata)\temp"

# Obtain the latest release off each github project  -- note: latest is always array item 0
$productMeta = (Invoke-WebRequest "https://api.github.com/repos/$githubProductOrg/$githubProductRepo/tags" | ConvertFrom-Json)[0]
$templateMeta = (Invoke-WebRequest "https://api.github.com/repos/$githubTemplateOrg/$githubTemplateRepo/tags" | ConvertFrom-Json)[0]

# Specify the file-system of the downloaded targets
$productZip = "$temp/Set-OutlookSignatures.zip"
$templateZip = "$temp/EmailTemplates.zip"

# Check if the latest version is already downloaded
If (Test-Path "$temp\$githubProductOrg-$githubProductRepo-$($($productMeta.commit.sha).substring(0,7))" ){
    Write-Host .. no need to download the product, a local copy already exists
} else {
    # Initiate the download
    Invoke-WebRequest "$($productMeta.zipball_url)" -Out $productZip
}
If (Test-Path "$temp\$githubTemplateOrg-$githubTemplateRepo-$($($templateMeta.commit.sha).substring(0,7))" ){
    Write-Host .. no need to download the product, a local copy already exists
} else {
    # Initiate the download
    Invoke-WebRequest "$($templateMeta.zipball_url)" -Out $templateZip
}

# Extract the zipball files to the temp directory, filename encoding needs converting to ascii, not utf8.
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($productZip, $temp, [System.Text.Encoding]::ascii)
[System.IO.Compression.ZipFile]::ExtractToDirectory($templateZip, $temp, [System.Text.Encoding]::ascii)

# Extract zip files to the temp directory
#Expand-Archive -Path $productZip -DestinationPath $temp -Force -ErrorAction SilentlyContinue
#Expand-Archive -Path $templateZip -DestinationPath $temp -Force -ErrorAction SilentlyContinue

# Gather some path data
$productPath = "$temp\$githubProductOrg-$githubProductRepo-$($($productMeta.commit.sha).substring(0,7))\src_Set-OutlookSignatures"
$templatePath = "$temp\$githubTemplateOrg-$githubTemplateRepo-$($($templateMeta.commit.sha).substring(0,7))"

# Clean up the downloaded content
Remove-Item -Path $productZip -Force
Remove-Item -Path $templateZip -Force


#Run product, with transcript logging, and args passed from variables above
Start-Transcript $temp\Set-OutlookSignatures.log -Append
powershell -executionpolicy bypass -windowstyle hidden -ScriptBlock { powershell $productPath\Set-OutlookSignatures.ps1 -graphonly $graphOnly -SignatureTemplatePath $templatePath\Signatures -SignatureIniPath $templatePath\Signatures\_Signatures.ini -SetCurrentUserOOFMessage $SetOofMsg -CreateRtfSignatures $CreateRtfSignatures -CreateTxtSignatures $CreateTxtSignatures -DisableRoamingSignatures $DisableRoamingSignatures -MirrorLocalSignaturesToCloud $MirrorLocalSignaturesToCloud }
Stop-Transcript 