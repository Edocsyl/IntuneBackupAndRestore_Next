function Invoke-IntuneBackupClientAppAssignment {
    <#
    .SYNOPSIS
    Backup Intune Client App Assignments
    
    .DESCRIPTION
    Backup Intune Client App  Assignments as JSON files per Client App to the specified Path.
    
    .PARAMETER Path
    Path to store backup files
    
    .EXAMPLE
    Invoke-IntuneBackupClientAppAssignment -Path "C:\temp"
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Set the Microsoft Graph API endpoint
    # #Select-MgProfile -Name $ApiVersion
    $url = "https://graph.microsoft.com/$ApiVersion"

    # Create folder if not exists
    if (-not (Test-Path "$Path\Client Apps\Assignments")) {
        $null = New-Item -Path "$Path\Client Apps\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $clientApps = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps?`$filter=(microsoft.graph.managedApp/appAvailability%20eq%20null%20or%20microsoft.graph.managedApp/appAvailability%20eq%20%27lineOfBusiness%27%20or%20isAssigned%20eq%20true)" | Get-MgGraphDataWithPagination).value

    foreach ($clientApp in $clientApps) {
        $assignments = Invoke-GraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceAppManagement/mobileApps/$($clientApp.Id)/assignments" -OutputType JSON | ConvertFrom-Json
        if ($assignments.value) {
            $fileName = ($clientApp.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$path\Client Apps\Assignments\$($clientApp.id) - $fileName.json"

            [PSCustomObject]@{
                "Action" = "Backup"
                "Type"   = "Client App Assignments"
                "Name"   = $clientApp.displayName
                "Path"   = "Client Apps\Assignments\$fileName.json"
            }
        }
    }
} 