<#
.SYNOPSIS
This script checks multiple registry paths for the last shutdown time and determines if a reboot is required based on a defined maximum uptime.

.DESCRIPTION
The script queries three specified registry paths to retrieve the last shutdown time recorded, which is stored in binary format. Converts from binary. 
If any of the paths contain a shutdown time older than the defined threshold, a flag is set to indicate that a reboot is required.

.VARIABLE maxUptimeInDays
The maximum number of days the system can run without shutting down before a reboot is required. Default value is 14 days.

.NOTES
Author: Thomas Klijnman
E-mail: < thomas.klijnman@pink.nl >
Date: 03/02/2026
#>

# Define vars
$maxUptimeInDays = 14
$regPaths = @(
    "HKLM:\SYSTEM\ControlSet001\Control\Windows",
    "HKLM:\SYSTEM\ControlSet002\Control\Windows",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Windows"
)

# Initialize the flag
$RebootPopUpIsRequired = $false

# Loop through each registry path
foreach ($regPath in $regPaths) {
    # Check if the registry path exists
    if (Test-Path $regPath) {
        # Read the binary value from the registry key
        $shutdownTimeBinary = Get-ItemProperty -Path $regPath -Name ShutdownTime
        
        # Convert the binary value to a datetime
        $shutdownTimestamp = ([BitConverter]::ToInt64($shutdownTimeBinary.ShutdownTime, 0))
        $shutdownDateTime = [System.DateTime]::FromFileTime($shutdownTimestamp)

        # Check if the shutdown time is older than the defined maximum uptime in days
        $currentDateTime = [System.DateTime]::Now
        if (($currentDateTime - $shutdownDateTime).Days -gt $maxUptimeInDays) {
            $RebootPopUpIsRequired = $true
            break  # Exit the loop if the condition is met
        }
    } else {
        # Path does not exist, continue to the next one
        $RebootPopUpIsRequired = $false
    }
}

