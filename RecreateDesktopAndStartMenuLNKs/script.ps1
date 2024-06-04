# Function to get the target path of a .lnk file
function Get-TargetPath {
    param (
        [string]$lnkPath
    )
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($lnkPath)
    return $shortcut.TargetPath
}

# Function to add or update a registry value
function Set-RegistryValue {
    param (
        [string]$keyPath,
        [string]$valueName,
        [string]$valueType,
        [string]$valueData
    )
    if ((Get-ItemProperty -Path $keyPath -Name $valueName -ErrorAction SilentlyContinue).$valueName -ne $valueData) {
        reg.exe add $keyPath /v $valueName /t $valueType /D $valueData /F
        Write-Output "Set $valueName to $valueData in $keyPath"
    } else {
        Write-Output "$valueName is already set to $valueData in $keyPath"
    }
}

# Function to get the current logged-in user
function Get-LoggedInUser {
    try {
        $user = (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName).Split('\')[1]
        return $user
    } catch {
        Write-Error "Unable to determine the logged-in user."
        exit 1
    }
}

# Get the current logged-in user's profile name
$UserName = Get-LoggedInUser

# Source directory containing the .lnk files
$sourcePath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"

# Set the destination path dynamically based on the current user's profile
$destinationPath = "C:\Users\$UserName\!!REDACTED!!\Bureaublad"

# Static list of .lnk files to process
$lnkList = @(
    "Acrobat Reader.lnk",
    "Excel.lnk",
    "Firefox.lnk",
    "Google Chrome.lnk",
    "KeePass 2.lnk",
    "Microsoft Edge.lnk",
    "Notepad++.lnk",
    "OneNote.lnk",
    "Outlook.lnk",
    "PowerPoint.lnk",
    "Visio.lnk",
    "Visual Studio 2022.lnk",
    "Word.lnk"
)

foreach ($lnkName in $lnkList) {
    # Get the full path of the .lnk file
    $lnkFullPath = Join-Path -Path $sourcePath -ChildPath $lnkName

    # Check if the .lnk file exists in the source directory
    if (Test-Path $lnkFullPath) {
        # Get the target path of the .lnk file
        $targetPath = Get-TargetPath -lnkPath $lnkFullPath

        # Check if the target path exists
        if (Test-Path $targetPath) {
            # Determine the destination path for the .lnk file in the destination directory
            $destinationLnkPath = Join-Path -Path $destinationPath -ChildPath $lnkName

            # Check if the .lnk file does not already exist in the destination directory
            if (-not (Test-Path $destinationLnkPath)) {
                # Copy the .lnk file to the destination directory
                Copy-Item -Path $lnkFullPath -Destination $destinationLnkPath
                Write-Output "Copied $lnkName to $destinationPath"
            } else {
                Write-Output "$lnkName already exists in $destinationPath"
            }
        } else {
            Write-Output "Target path for $lnkName does not exist: $targetPath"
        }
    } else {
        Write-Output "$lnkName does not exist in $sourcePath"
    }
}

# Step 3: Modify Local Machine settings - Change Start Menu look & feel, Explorer and Lockscreen
Write-Host "Modify Local Machine settings - Change Start Menu look & feel, Explorer and Lockscreen"
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -valueName "NoCommonGroups" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -valueName "NoSearchProgramsInStartMenu" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -valueName "NoSearchInternetInStartMenu" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -valueName "DisableContextMenusInStart" -valueType "REG_DWORD" -valueData 0

# Step 4: Modify Local Machine settings - Hiding Explorer Items: 1: Networking, 2: 3D Objects, 3: Music and 4: Videos
Write-Host "Modify Local Machine settings - Hiding Explorer Items: 1: Networking, 2: 3D Objects, 3: Music and 4: Videos"
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -valueName "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -valueName "{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -valueName "{3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\NonEnum" -valueName "{F86FA3AB-70D2-4FC7-9C99-FCBF05467F3A}" -valueType "REG_DWORD" -valueData 0

# Step 5: Default file association
Write-Host "Delete custom file association"
reg.exe delete "HKCR\Applications\_CUSTOM_ACTION.exe" /F

# Step 6: Restore provisioned apps
Write-Host "Restore provisioned apps"
Get-AppxPackage -AllUsers *shellexperience* -PackageTypeFilter Bundle | ForEach-Object { Add-AppxPackage -Register -DisableDevelopmentMode ($_.InstallLocation + “\AppxMetadata\AppxBundleManifest.xml”) }

# Step 8: Additional registry settings
Write-Host "Add additional registry settings"
Set-RegistryValue -keyPath "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -valueName "DisableEdgeDesktopShortcutCreation" -valueType "REG_DWORD" -valueData 0
Set-RegistryValue -keyPath "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" -valueName "CreateDesktopShortcutDefault" -valueType "REG_DWORD" -valueData 1

# Copy the entire Start Menu to the new location, ensuring the destination does not already have the files
$completeSourcePath = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*"
$completeDestinationPath = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"

if (-not (Test-Path $completeDestinationPath)) {
    Write-Output "Copying entire Start Menu contents to $completeDestinationPath"
    Copy-Item -Path $completeSourcePath -Destination $completeDestinationPath -Recurse -Force
    Write-Output "Completed copying Start Menu contents."
} else {
    Write-Output "The destination $completeDestinationPath already exists."
}
