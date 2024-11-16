# Installation script for Mouse Reset

$ErrorActionPreference = 'Stop'

try {
    # Create log directory and start transcript
    $logPath = "C:\Program Files\PNG\Scripts\Journaux"
    $logFile = Join-Path $logPath "mouse-reset-install.log"
    New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    Start-Transcript -Path $logFile -Force

    # Define paths using environment variables
    $installRoot = Join-Path $env:ProgramData "PNG\Scripts\Mouse"
    
    # Create directory
    Write-Host "Creating directory..."
    New-Item -ItemType Directory -Path $installRoot -Force | Out-Null
    
    # Copy files
    Write-Host "Copying files..."
    Copy-Item -Path ".\mouse.ps1" -Destination $installRoot -Force
    
    # Load and modify the XML content
    Write-Host "Preparing task configuration..."
    $taskXml = Get-Content (Join-Path $PSScriptRoot "mouse_reset.xml") -Raw
    
    # Replace the script path placeholder with actual path
    $taskXml = $taskXml.Replace("%SCRIPTPATH%", $installRoot)
    
    # Register scheduled task
    Write-Host "Registering scheduled task..."
    $taskName = "mouse_reset"
    
    # Remove existing task if it exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed existing task"
    }
    
    # Register the task
    $null = Register-ScheduledTask -TaskName $taskName -Xml $taskXml -Force
    Write-Host "Successfully registered task"
    
    # Set appropriate permissions
    Write-Host "Setting permissions..."
    
    # Get current ACL
    $acl = Get-Acl $installRoot
    
    # Create rule for SYSTEM
    $systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
    $systemRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $systemSid,
        "FullControl",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($systemRule)
    
    # Create rule for Users group
    $usersGroup = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
    $usersRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $usersGroup,
        "ReadAndExecute",
        "ContainerInherit,ObjectInherit",
        "None",
        "Allow"
    )
    $acl.AddAccessRule($usersRule)
    
    # Apply ACL to install directory
    Set-Acl $installRoot $acl
    
    # Start the task
    Write-Host "Starting task..."
    Start-ScheduledTask -TaskName $taskName
    
    Write-Host "Installation completed successfully"
    Write-Host "Files installed to: $installRoot"
}
catch {
    Write-Error "Installation failed: $_"
    Stop-Transcript
    exit 1
}

Stop-Transcript
