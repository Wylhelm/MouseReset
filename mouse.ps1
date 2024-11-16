# Reset Mouse Settings to Default Values for Current User
# This script resets mouse sensitivity, speed, thresholds and button configuration to Windows 11 defaults

# Initialize exit code
$script:exitCode = 0

# Function to apply mouse settings for current user
function Set-CurrentUserMouseSettings {
    $currentUserRegistryPath = "HKCU:\Control Panel\Mouse"
    
    # Default Windows 11 mouse settings
    $mouseSettings = @{
        "MouseSensitivity" = "10"    # Default sensitivity
        "MouseSpeed" = "0"           # Default speed (0 = no acceleration)
        "MouseThreshold1" = "0"      # First acceleration threshold (0 = disabled)
        "MouseThreshold2" = "0"      # Second acceleration threshold (0 = disabled)
        "SmoothMouseXCurve" = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x15,0x6e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x01,0x00,0x00,0x00,0x00,0x00,0x29,0xdc,0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x00,0x00,0x00))
        "SmoothMouseYCurve" = ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfd,0x11,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x24,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,0x12,0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0xbb,0x01,0x00,0x00,0x00,0x00))
        "DoubleClickSpeed" = "500"   # Default double-click speed
        "MouseTrails" = "0"         # Disable mouse trails
        "SnapToDefaultButton" = "0"  # Disable snap to default button
        "SwapMouseButtons" = "0"     # Normal button configuration
    }

    $success = $true
    
    # Apply mouse settings
    foreach ($setting in $mouseSettings.GetEnumerator()) {
        try {
            if ($setting.Key -like "SmoothMouse*Curve") {
                Set-ItemProperty -Path $currentUserRegistryPath -Name $setting.Key -Value $setting.Value -Type Binary -ErrorAction Stop
            } else {
                Set-ItemProperty -Path $currentUserRegistryPath -Name $setting.Key -Value $setting.Value -Type String -ErrorAction Stop
            }
            Write-Host ("Successfully set {0} in Mouse settings" -f $setting.Key) -ForegroundColor Green
        }
        catch {
            $errorMessage = "Failed to set {0} in Mouse settings. Error: {1}" -f $setting.Key, $_.Exception.Message
            Write-Host $errorMessage -ForegroundColor Red
            $success = $false
            $script:exitCode = 1
        }
    }

    # Apply system-wide mouse settings
    if (-not ("Win32.NativeMethods" -as [type])) {
        Add-Type -MemberDefinition @'
        [DllImport("user32.dll")]
        public static extern bool SwapMouseButton(bool swap);
        [DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
        public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, uint pvParam, uint fWinIni);
'@ -Name "NativeMethods" -Namespace Win32
    }

    try {
        # Reset to normal button configuration
        $null = [Win32.NativeMethods]::SwapMouseButton($false)
        Write-Host "Successfully restored mouse buttons to normal configuration" -ForegroundColor Green

        # Set mouse speed
        $SPI_SETMOUSESPEED = 0x0071
        $SPIF_UPDATEINIFILE = 0x01
        $SPIF_SENDCHANGE = 0x02
        $null = [Win32.NativeMethods]::SystemParametersInfo($SPI_SETMOUSESPEED, 0, 10, ($SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE))
        Write-Host "Successfully set mouse speed to default" -ForegroundColor Green
    }
    catch {
        Write-Host ("Failed to apply system settings. Error: {0}" -f $_.Exception.Message) -ForegroundColor Red
        $success = $false
        $script:exitCode = 1
    }

    # Refresh user settings
    try {
        $null = Start-Process -FilePath "rundll32.exe" -ArgumentList "user32.dll,UpdatePerUserSystemParameters 1, True" -Wait
        Write-Host "Successfully refreshed settings" -ForegroundColor Green
    }
    catch {
        Write-Host ("Failed to refresh settings. Error: {0}" -f $_.Exception.Message) -ForegroundColor Red
        $success = $false
        $script:exitCode = 1
    }

    return $success
}

try {
    Write-Host "Starting mouse settings reset script for current user" -ForegroundColor Green
    
    # Apply mouse settings for current user
    $success = Set-CurrentUserMouseSettings
    
    if ($success) {
        Write-Host "Successfully processed mouse settings for current user" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to process some mouse settings" -ForegroundColor Yellow
        $script:exitCode = 1
    }
}
catch {
    Write-Host ("Critical error in script execution: {0}" -f $_.Exception.Message) -ForegroundColor Red
    $script:exitCode = 1
}
finally {
    Write-Host ("Script execution finished with exit code: {0}" -f $script:exitCode) -ForegroundColor Green
    exit $script:exitCode
}
