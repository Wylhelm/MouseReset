# Mouse Settings Reset Solution

## Description
Automated solution to reset Windows mouse settings to default values. This solution is deployed via Microsoft Intune and runs automatically at user login and after a period of inactivity.

## Features
- Automatic reset of mouse settings
- Execution at user login
- Execution after 5 minutes of inactivity
- Complete action logging
- Deployment via Microsoft Intune

## Project Structure
```
.
├── Detection.ps1          # Detection script for Intune
├── Install.cmd           # Installation wrapper script
├── Install.intunewin     # Intune package
├── Install.ps1           # Main installation script
├── IntuneWinAppUtil.exe  # Intune package creation utility
├── mouse_reset.xml       # Scheduled task configuration
├── mouse.ps1            # Main reset script
├── Uninstall.cmd        # Uninstallation wrapper script
└── Uninstall.ps1        # Main uninstallation script
```

## Prerequisites
- Windows 11
- Administrative rights for installation
- Microsoft Intune for deployment

## Installation
Installation is handled automatically through Microsoft Intune. The `.intunewin` package contains all necessary components and configures:
1. Reset scripts
2. Scheduled task
3. Required permissions
4. Logging

## Logging
Logs are stored in:
- `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-install.log`
- `C:\Program Files\PNG\Scripts\Journaux\mouse-reset-detection.log`

## Documentation
For more technical details, see the [Developer Guide](developer_guide.md).

## Support
In case of issues:
1. Check log files
2. Consult the troubleshooting section in the developer guide
3. Check scheduled task status via Windows Task Scheduler

## License
Proprietary - All rights reserved
