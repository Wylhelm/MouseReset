# Register the mouse reset scheduled task
#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

try {
    # Define paths
    $scriptRoot = Join-Path $env:ProgramData "PNG\Scripts\Mouse"
    $scriptPath = Join-Path $scriptRoot "mouse.ps1"
    $taskPath = Join-Path $scriptRoot "mouse_reset.xml"
    $logDir = Join-Path $scriptRoot "Logs"
    
    # Create directories if they don't exist
    @($scriptRoot, $logDir) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Host "Created directory: $_"
        }
    }
    
    # Copy files to ProgramData
    Copy-Item -Path ".\mouse.ps1" -Destination $scriptPath -Force
    Copy-Item -Path ".\mouse_reset.xml" -Destination $taskPath -Force
    Write-Host "Copied script and task files to $scriptRoot"
    
    # Set proper permissions
    $acl = Get-Acl $scriptRoot
    $acl.SetAccessRuleProtection($true, $false) # Disable inheritance and remove inherited permissions
    
    # Add necessary permissions
    $rules = @(
        # SYSTEM full control
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            "NT AUTHORITY\SYSTEM", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
        ),
        # Administrators full control
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            "BUILTIN\Administrators", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
        ),
        # Users read & execute
        New-Object System.Security.AccessControl.FileSystemAccessRule(
            "BUILTIN\Users", "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
        )
    )
    
    foreach ($rule in $rules) {
        $acl.AddAccessRule($rule)
    }
    
    # Apply ACL to script root and propagate to children
    Set-Acl -Path $scriptRoot -AclObject $acl
    Write-Host "Set permissions on $scriptRoot"
    
    # Register the scheduled task
    $taskName = "mouse_reset"
    
    # Remove existing task if it exists
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "Removed existing task: $taskName"
    }
    
    # Register new task
    Register-ScheduledTask -Xml (Get-Content $taskPath -Raw) -TaskName $taskName -Force
    Write-Host "Successfully registered task: $taskName"
    
    # Verify task registration
    $task = Get-ScheduledTask -TaskName $taskName
    if ($task) {
        Write-Host "Task verification successful. Current status: $($task.State)"
        
        # Start the task to verify it works
        Start-ScheduledTask -TaskName $taskName
        Write-Host "Started task for initial verification"
    } else {
        throw "Task verification failed"
    }
}
catch {
    Write-Error "Failed to register task: $_"
    exit 1
}
