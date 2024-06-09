# Configuration: number of days to consider as old
$daysOld = 30

# Function to check if a profile is older than a certain number of days
function IsProfileOlderThan {
    param (
        [string]$profilePath,
        [int]$daysOld
    )

    $lastWriteTime = (Get-Item $profilePath).LastWriteTime
    $age = (Get-Date) - $lastWriteTime
    return $age.Days -ge $daysOld
}

# Function to clean up registry keys
function CleanupRegistryKeys {
    param (
        [string]$baseRegistryPath,
        [int]$daysOld
    )

    # Loop through all subkeys in the given registry path
    Get-ChildItem -Path $baseRegistryPath | ForEach-Object {
        $subKeyPath = $_.PSPath
        $samName = Get-ItemProperty -Path $subKeyPath | Select-Object -ExpandProperty SAMName -ErrorAction SilentlyContinue
        
        # Check if the SAMName contains the NETBIOS of {NETBIOS}
        if ($samName -match "^{NETBIOS}\\") {
            $userName = $samName -replace "^{NETBIOS}\\", ""

            # Compare with profiles under C:\Users and ProfileList
            $profilePath = "C:\Users\$userName"
            $profileRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

            if (Test-Path $profilePath -and IsProfileOlderThan -profilePath $profilePath -daysOld $daysOld) {
                # Remove the registry key if the profile is old
                Remove-Item -Path $subKeyPath -Recurse -Force
                Write-Host "Removed registry key: $subKeyPath"
            }
        }
    }
}

# Base registry path
$baseRegistryPath = "HKLM:\SOFTWARE\Microsoft\IdentityStore\LogonCache"

# Call the cleanup function
CleanupRegistryKeys -baseRegistryPath $baseRegistryPath -daysOld $daysOld
