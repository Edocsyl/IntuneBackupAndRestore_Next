function Invoke-IntuneBackupDeviceCompliancePolicyAssignment {
    <#
    .SYNOPSIS
    Backup Intune Device Complaince Policy Assignments
    
    .DESCRIPTION
    Backup Intune Device Complaince Policy Assignments as JSON files per Device Compliance Policy to the specified Path.
    
    .PARAMETER Path
    Path to store backup files
    
    .EXAMPLE
    Invoke-IntuneBackupDeviceCompliancePolicyAssignment -Path "C:\temp"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # # Set the Microsoft Graph API endpoint
    # if (-not ((Get-MSGraphEnvironment).SchemaVersion -eq $apiVersion)) {
    #     Update-MSGraphEnvironment -SchemaVersion $apiVersion -Quiet
        Connect-MgGraph
    # }

    # Create folder if not exists
    if (-not (Test-Path "$Path\Device Compliance Policies\Assignments")) {
        $null = New-Item -Path "$Path\Device Compliance Policies\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $deviceCompliancePolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies" | Get-MgGraphDataWithPagination).value

    foreach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
        $assignments = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies/$($deviceCompliancePolicy.id)/assignments").value
        if ($assignments) {
            $fileName = ($deviceCompliancePolicy.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\Device Compliance Policies\Assignments\$fileName.json"

            [PSCustomObject]@{
                "Action" = "Backup"
                "Type"   = "Device Compliance Policy Assignments"
                "Name"   = $deviceCompliancePolicy.displayName
                "Path"   = "Device Compliance Policies\Assignments\$fileName.json"
            }
        }
    }
}