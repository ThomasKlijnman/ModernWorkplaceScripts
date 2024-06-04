# PowerShell Script for Configuring User Environment

This PowerShell script is designed to configure the user environment by copying specific `.lnk` files to the user's desktop and making various registry modifications to customize the Start Menu, Explorer, and other settings. The script dynamically determines the logged-in user and applies the settings accordingly.

## Prerequisites

- The script must be run with administrative privileges.
- Ensure PowerShell is available on the system.

## Features

1. **Copy .lnk Files**: Copies a predefined list of `.lnk` files from the source directory to the user's desktop.
2. **Registry Modifications**:
   - Customizes the Start Menu look and feel.
   - Hides specific items in Windows Explorer.
   - Modifies other system settings to enhance user experience.
