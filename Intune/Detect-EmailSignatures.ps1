<#
.SYNOPSIS
    PowerShell script to detect an existing Email Signatures log, from Set-OutlookSignatures script.

.EXAMPLE
    .\Detect-EmailSignatures.ps1

.DESCRIPTION
    This PowerShell script is deployed as a detection script using Microsoft Intune remediations.

.LINK
    https://github.com/alltimeuk/EmailTemplates/blob/main/Intune/Detect-EmailSignatures.ps1

.LINK
    https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/overview-endpoint-detection-response

.NOTES
    Version:        1.0
    Creation Date:  2023-11-07
    Last Updated:   2023-11-07
    Author:         Simon Jackson @ Alltime Technologies Ltd
    Organization:   Alltime Technologies Ltd
    Contact:        sjackson0109 @ jacksonfamily . me

#>
#Look in the localappdata\temp folder
$temp = "$($env:localappdata)\temp"
$file = "$temp\Set-OutlookSignatures.log"

# Check if the log file exists
If (Test-Path $file ){
    Write-Host "Email Signatures LOG found."
    If ( $(Get-Date).AddHours(-2) -gt $(Get-Item $file).LastWriteTime  ) {
        Write-Host "Log file written to within the last 2 hours. Exiting."
        exit 0
    } Else {
        Write-Host "Log is old. Remediation Required."
        exit 1
    }
}
Else {
    Write-Host "Email Signatures LOG not found. Remediation Required."
    exit 1
}