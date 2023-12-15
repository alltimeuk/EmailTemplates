<#
.SYNOPSIS
    PowerShell script to detect an existing Email Signatures log, from Set-OutlookSignatures script.

.EXAMPLE
    .\Detect-EmailSignatures.ps1

.DESCRIPTION
    This PowerShell script is deployed as a detection script using Microsoft Intune remediations.

.LINK
    https://github.com/sjackson0109/Set-EmailSignatures/blob/main/Intune/Detect-EmailSignatures.ps1

.LINK
    https://github.com/Set-OutlookSignatures/Set-OutlookSignatures
    
.LINK
    https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/overview-endpoint-detection-response

.NOTES
    Version:        1.0.3
    Creation Date:  2023-11-07
    Last Updated:   2023-12-11
    Author:         Simon Jackson / sjackson0109
    Contact:        simon@jacksonfamily.me
#>
#Look in the localappdata\temp folder
$temp = "$($env:localappdata)\temp"
$logFile = "$temp\Set-OutlookSignatures.log"
$addHours = 2 # Start with 2 hours, after a couple of weeks move it to 24 hours

# Check if the log file exists
If (Test-Path $logFile ){
    If ( $(Get-Item $logFile).LastWriteTime -gt $(Get-Date).AddHours(-$addHours) ) {
        Write-Host "NEW log found. Remediation NOT required"
        exit 0
    } Else {
        Write-Host "OLD log found. Remediation required."
        exit 1
    }
}
Else {
    Write-Host "NO LOG found. Remediation required."
    exit 1
}