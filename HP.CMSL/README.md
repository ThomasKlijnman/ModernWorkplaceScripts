# PowerShell Script for running default BIOS setup on HP.CMSL

This PowerShell script automates the process of applying the default BIOS setup on HP computers using the HP Client Management Script Library (HP.CMSL).

## Prerequisites

1. **PowerShell 5.1 or later**:
   Ensure you have PowerShell 5.1 or a later version installed on your system.

2. **HP Client Management Script Library (HP.CMSL)**:
   - Download and install the HP Client Management Script Library
   - Follow the installation instructions provided in the repository.

3. **Administrator Privileges**:
   Run the script with administrator privileges to ensure it can make the necessary changes to the BIOS settings.

## Usage

1. **Clone or Download the Script**:
   - Clone this repository or download the script file directly to your local machine.

2. **Open PowerShell as Administrator**:
   - Right-click on the PowerShell icon and select "Run as administrator".
   - Run the script

2.1 **Run script remote**:
   - Open Powershell as Administrator
   - Run: ' iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ThomasKlijnman/ModernWorkplaceScripts/main/HP.CMSL/DetectionAndRun-HPCSML.ps1')) '
