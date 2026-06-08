
#requires -Version 5.1
<#
.SYNOPSIS
  Installs Visual C++ Redistributables using inline logic (no external script) with retry & validation.

.OUTPUTS
  Log file at C:\ProgramData\POSD\Logs\Install-VCRedist.log
#>

$ProgressPreference = 'SilentlyContinue'

# Declarations
$ScriptVersion = '1.2'
$LogPath = "$env:ProgramData\POSD\Logs"
$LogName = 'Install-VCRedist.log'
$LogFile = Join-Path -Path $LogPath -ChildPath $LogName

# Ensure log directory exists
if (-not (Test-Path -Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

#--------------------------- Functions ---------------------------

function Test-VCRedistInstalled {
    param(
        [ValidateSet('x64','x86')]
        [string]$Arch
    )

    $expectedName = switch ($Arch) {
        "x64" { "Microsoft Visual C++ 2015-2022 Redistributable (x64)" }
        "x86" { "Microsoft Visual C++ 2015-2022 Redistributable (x86)" }
    }

    $registryPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($path in $registryPaths) {
        foreach ($key in Get-ChildItem -Path $path -ErrorAction SilentlyContinue) {
            $props = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
            if ($props.DisplayName -like "*$expectedName*") { return $true }
        }
    }
    return $false
}

function Ensure-Prereqs {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        # Try to import PowerShellGet (graceful if absent)
        try { Import-Module PowerShellGet -ErrorAction SilentlyContinue } catch { }

        # Ensure NuGet provider (avoid interactive bootstrap prompts)
        $nuget = Get-PackageProvider -Name 'NuGet' -ListAvailable -ErrorAction SilentlyContinue
        if (-not $nuget) {
            Write-Host "NuGet provider not found. Installing NuGet provider..."
            Install-PackageProvider -Name 'NuGet' -MinimumVersion 2.8.5.208 -Force -Scope AllUsers -ErrorAction Stop
            Import-PackageProvider -Name 'NuGet' -Force -ErrorAction SilentlyContinue
        }

        # Ensure PSGallery exists and is trusted
        $repo = Get-PSRepository -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'PSGallery' }
        if (-not $repo) {
            Write-Host "PSGallery not registered. Registering default repositories..."
            Register-PSRepository -Default -ErrorAction SilentlyContinue
            $repo = Get-PSRepository -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'PSGallery' }
        }

        if ($repo -and $repo.InstallationPolicy -ne "Trusted") {
            Write-Host "Trusting the repository: PSGallery."
            Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
        }
    }
    catch {
        Write-Warning "Failed to ensure PowerShellGet prerequisites. Error: $_"
    }
}

function Run-VcRedistInline {
    param(
        [string]$CachePath = "$env:TEMP\VcRedist"
    )
    try {
        Ensure-Prereqs

        # ---- BEGIN: Inline content equivalent to install.ps1 ----
        $Module = "VcRedist"
        Write-Host "Checking whether module is installed: $Module."

        $installedModule = Get-Module -Name $Module -ListAvailable -ErrorAction SilentlyContinue |
            Sort-Object @{ Expression = { [version] $_.Version }; Descending = $true } |
            Select-Object -First 1

        $publishedModule = $null
        try {
            $publishedModule = Find-Module -Name $Module -ErrorAction Stop
        } catch {
            Write-Warning "Could not query PSGallery for '$Module'. Continuing with installed module if present. Error: $_"
        }

        if (($null -eq $installedModule) -or ($publishedModule -and ([version]$publishedModule.Version -gt [version]$installedModule.Version))) {
            $targetVersionText = if ($publishedModule) { $publishedModule.Version } else { "latest available" }
            Write-Host "Installing/Updating module: $Module $targetVersionText"
            Install-Module -Name $Module -SkipPublisherCheck -Force -ErrorAction Stop
        }

        Write-Host "Saving VcRedists to path: $CachePath."
        New-Item -Path $CachePath -ItemType "Directory" -Force -ErrorAction SilentlyContinue | Out-Null

        Write-Host "Downloading and installing supported Microsoft Visual C++ Redistributables."
        if ($Env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            Write-Host "64-bit system detected."
            $Architecture = "x86", "x64"
        } elseif ($Env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
            Write-Host "ARM64 system detected."
            $Architecture = "x86", "x64", "arm64"
        } else {
            # Fallback (x86 only)
            $Architecture = "x86"
        }

        $Redists = Get-VcList -Architecture $Architecture |
            Save-VcRedist -Path $CachePath |
            Install-VcRedist -Silent

        Write-Host "Installed Visual C++ Redistributables:"
        $Redists | Select-Object -Property "Name", "Release", "Architecture", "Version" -Unique
        # ---- END: Inline content equivalent to install.ps1 ----
    }
    catch {
        Write-Warning "Failed to run inline VcRedist installer. Error: $_"
        throw
    }
}

#--------------------------- Execution ---------------------------

Start-Transcript -Path $LogFile -Append

$maxAttempts = 3
$attempt = 1

do {
    Write-Output "[$(Get-Date -Format 'u')] Validation attempt $attempt of $maxAttempts..."

    $x64Installed = Test-VCRedistInstalled -Arch "x64"
    $x86Installed = Test-VCRedistInstalled -Arch "x86"

    if ($x64Installed -and $x86Installed) {
        Write-Output "[$(Get-Date -Format 'u')] Both x64 and x86 VC++ Redistributables are installed."
        break
    } else {
        if (-not $x64Installed) { Write-Warning "x64 Redistributable NOT detected." }
        if (-not $x86Installed) { Write-Warning "x86 Redistributable NOT detected." }

        if ($attempt -lt $maxAttempts) {
            Run-VcRedistInline -CachePath "$env:TEMP\VcRedist"
            Start-Sleep -Seconds 10
        }

        $attempt++
    }

} while ($attempt -le $maxAttempts)

# Final check + exit code
if (-not (Test-VCRedistInstalled -Arch "x64") -or -not (Test-VCRedistInstalled -Arch "x86")) {
    Write-Error "[$(Get-Date -Format 'u')] FAILED: One or both redistributables not installed after $maxAttempts attempts."
    Stop-Transcript
    exit 1
} else {
    Write-Output "[$(Get-Date -Format 'u')] SUCCESS: Both redistributables are confirmed installed."
    Stop-Transcript
    exit 0
}
