function Invoke-IntuneBackupWindowsDriverUpdateProfiles {
    <#
    .SYNOPSIS
    Backup Intune Settings Catalog Policies
    
    .DESCRIPTION
    Backup Intune Settings Catalog Policies as JSON files per Settings Catalog Policy to the specified Path.
    
    .PARAMETER Path
    Path to store backup files
    
    .EXAMPLE
    Invoke-IntuneBackupWindowsDriverUpdateProfiles -Path "C:\temp"
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

    # Create folder if not exists
    if (-not (Test-Path "$Path\Windows Driver Update Profiles")) {
        $null = New-Item -Path "$Path\Windows Driver Update Profiles" -ItemType Directory
    }

    # Get all Setting Catalogs Policies
    $windowsDriverUpdateProfiles = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsDriverUpdateProfiles" | Get-MgGraphDataWithPagination).value 

    foreach ($windowsDriverUpdateProfile in $windowsDriverUpdateProfiles) {
        $settings = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsDriverUpdateProfiles/$($windowsDriverUpdateProfile.id)" | Get-MgGraphDataWithPagination

        if ($settings -isnot [System.Array]) {
            $windowsDriverUpdateProfile.Settings = @($settings)
        } else {
            $windowsDriverUpdateProfile.Settings = $settings
        }
        
        $fileName = ($windowsDriverUpdateProfile.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $windowsDriverUpdateProfile | ConvertTo-Json -Depth 100 | Out-File -LiteralPath "$path\Windows Driver Update Profiles\$fileName.json"

        [PSCustomObject]@{
            "Action" = "Backup"
            "Type"   = "Windows Driver Update Profiles"
            "Name"   = $windowsDriverUpdateProfile.name
            "Path"   = "Windows Driver Update Profiles\$fileName.json"
        }
    }
}
