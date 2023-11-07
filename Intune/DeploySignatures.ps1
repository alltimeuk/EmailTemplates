#Gloabl Init
[string]$temp = [environment]::getfolderpath('TEMP')

#Variables for Set-OutlookSignatures
$githubProductOrg = "Set-OutlookSignatures"
$githubProductRepo = "Set-OutlookSignatures"
$githubTemplateOrg = "alltimeuk"
$githubTemplateRepo = "EmailTemplates"

# Obtain the latest release off each github project  -- note: latest is always array item 0
$productMeta = (Invoke-WebRequest "https://api.github.com/repos/$githubProductOrg/$githubProductRepo/tags" | ConvertFrom-Json)[0]
$templateMeta = (Invoke-WebRequest "https://api.github.com/repos/$githubTemplateOrg/$githubTemplateRepo/tags" | ConvertFrom-Json)[0]

$productZip = "$temp/Set-OutlookSignatures.zip"
$templateZip = "$temp/EmailTemplates.zip"

Invoke-WebRequest "$($productMeta.zipball_url)" -Out $productZip
Invoke-WebRequest "$($templateMeta.zipball_url)" -Out $templateZip


Expand-Archive -Path $productZip -DestinationPath $temp #-Force
Expand-Archive -Path $templateZip -DestinationPath $temp #-Force

# Clean up the downloaded content
Remove-Item -Path $productZip -Force
Remove-Item -Path "$temp/EmailTemplates.zip" -Force


#Run
#.\$temp\EmailSignatures\src_set-OutlookSignatures\Set-OutlookSignatures.ps1 -graphonly true -SignatureTemplatePath .\$temp\private\Signatures -SignatureIniPath .\$temp\private\Signatures\_Signatures.ini -SetCurrentUserOOFMessage false -CreateRtfSignatures true -CreateTxtSignatures true -DisableRoamingSignatures false -MirrorLocalSignaturesToCloud true