# Developer Guide - Mouse Settings Reset Solution

## Overview

This solution is designed to automatically reset Windows mouse settings to default values. It is deployed via Microsoft Intune as a Win32 application and uses Windows scheduled tasks to run at specific times.

## Solution Architecture

### Main Components

1. **Main Script (mouse.ps1)**
   - Resets mouse settings to Windows 11 default values
   - Configures sensitivity, speed, thresholds, and button configuration
   - Uses Windows APIs to apply settings
   - Logs all actions performed

2. **Scheduled Task (mouse_reset.xml)**
   - Runs under two conditions:
     * At user login
     * After 5 minutes of inactivity
   - Configured to run with highest available privileges
   - Uses current user account

3. **Deployment Scripts**
   - **Install.ps1**: Main installation script
   - **Uninstall.ps1**: Uninstallation script
   - **Detection.ps1**: Detection script for Intune
   - **Install.cmd** and **Uninstall.cmd**: PowerShell execution wrappers

### Directory Structure

```
%ProgramData%\PNG\Scripts\Mouse\
    └── mouse.ps1

%ProgramFiles%\PNG\Scripts\Journaux\
    ├── mouse-reset-install.log
    └── mouse-reset-detection.log
```

## Installation Process

1. Creation of necessary directories
2. Copying files to appropriate locations
3. Permission configuration:
   - SYSTEM: Full control
   - Users: Read and execute
4. Scheduled task registration
5. Initial task startup

## Detection Mechanism

The detection script (`Detection.ps1`) checks:
1. Presence of all required files
2. Existence and status of scheduled task
3. Correct directory permissions
4. Performs up to 3 detection attempts with a 10-second delay

## Logging

- Installation logs: `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-install.log`
- Detection logs: `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-detection.log`
- Log format: `[Date-Time] [Level] Message`

## Configured Mouse Settings

The following settings are reset to default values:
- Mouse sensitivity (MouseSensitivity)
- Pointer speed (MouseSpeed)
- Acceleration thresholds (MouseThreshold1, MouseThreshold2)
- Movement curves (SmoothMouseXCurve, SmoothMouseYCurve)
- Double-click speed (DoubleClickSpeed)
- Pointer trails (MouseTrails)
- Button configuration (SwapMouseButtons)

## Intune Deployment

### Prerequisites
- Administrative access to Microsoft Intune
- `.intunewin` package generated with `IntuneWinAppUtil.exe`

### Deployment Commands
- Installation: `Install.cmd`
- Uninstallation: `Uninstall.cmd`
- Detection: `powershell.exe -ExecutionPolicy Bypass -File Detection.ps1`

## Troubleshooting

### Common Issues
1. **Task doesn't execute**
   - Check permissions
   - Check Windows event logs
   - Verify scheduled task status

2. **Detection failure**
   - Check logs in `C:\Program Files\PNG\Scripts\Journaux`
   - Ensure all files are present
   - Check directory permissions

### Useful Commands
```powershell
# Check task status
Get-ScheduledTask -TaskName "mouse_reset"

# Check permissions
Get-Acl "%ProgramData%\PNG\Scripts\Mouse"

# Run task manually
Start-ScheduledTask -TaskName "mouse_reset"
```

## Maintenance and Updates

To update the solution:
1. Modify necessary scripts
2. Update version in Intune package
3. Regenerate `.intunewin` file
4. Deploy new version via Intune

## Security

- Scripts run with necessary elevated privileges
- Permissions are strictly controlled
- Paths are hardcoded to prevent injection attacks
- PowerShell execution policy is securely configured

## Development Best Practices

1. Always test changes locally before deployment
2. Maintain up-to-date documentation of changes
3. Use version control to track modifications
4. Test on different Windows versions
5. Validate logs after each modification
