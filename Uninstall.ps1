# Uninstallation script for Mouse Reset

$ErrorActionPreference = 'Stop'

try {
    # Define paths using environment variables
    $installRoot = Join-Path $env:ProgramData "PNG\Scripts\Mouse"
    $logFile = "C:\Program Files\PNG\Scripts\Journaux\mouse-reset-uninstall.log"
    
    # Create log directory if it doesn't exist
    $logDir = Split-Path $logFile
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    # Start logging
    Start-Transcript -Path $logFile -Force
    Write-Host "Starting uninstallation process..."
    
    # Remove scheduled task
    Write-Host "Removing scheduled task..."
    $taskName = "mouse_reset"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed task"
    }
    else {
        Write-Host "Task not found"
    }
    
    # Remove installation directory
    if (Test-Path $installRoot) {
        Write-Host "Removing installation directory..."
        Remove-Item -Path $installRoot -Recurse -Force
        Write-Host "Removed installation directory"
        
        # Try to remove parent directories if empty
        $parentDir = Split-Path $installRoot
        while ($parentDir -and (Test-Path $parentDir)) {
            $items = Get-ChildItem -Path $parentDir -Force
            if ($items.Count -eq 0) {
                Remove-Item -Path $parentDir -Force
                $parentDir = Split-Path $parentDir
            }
            else {
                break
            }
        }
    }
    
    # Clean up any temporary XML files that might have been created
    Get-ChildItem -Path $env:TEMP -Filter "temp_task*.xml" | ForEach-Object {
        try {
            Remove-Item -Path $_.FullName -Force
            Write-Host "Removed temporary file: $($_.Name)"
        }
        catch {
            Write-Warning "Failed to remove temporary file $($_.Name): $_"
        }
    }
    
    Write-Host "Uninstallation completed successfully"
}
catch {
    Write-Error "Uninstallation failed: $_"
    Stop-Transcript
    exit 1
}

Stop-Transcript
