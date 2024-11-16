# Detection script for Mouse Reset Solution
$ErrorActionPreference = "SilentlyContinue"

$logPath = "C:\Program Files\PNG\Scripts\Journaux"
$detectionLog = Join-Path $logPath "mouse-reset-detection.log"

function Write-DetectionLog {
    param(
        [string]$Message,
        [string]$Level = 'Information'
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Level] $Message"
    
    try {
        if (-not (Test-Path $logPath)) {
            New-Item -ItemType Directory -Path $logPath -Force | Out-Null
        }
        $logEntry | Out-File -FilePath $detectionLog -Append -Force
        Write-Host $logEntry
    }
    catch {
        Write-Host "Failed to write to log file: $_"
    }
}

function Test-Components {
    # Define paths using environment variables to match Install.ps1
    $installRoot = Join-Path $env:ProgramData "PNG\Scripts\Mouse"
    
    $requiredFiles = @(
        (Join-Path $installRoot "mouse.ps1")
    )

    $taskName = "mouse_reset"

    # Check if all required files exist and are accessible
    $filesExist = $true
    foreach ($file in $requiredFiles) {
        if (-not (Test-Path $file -PathType Leaf)) {
            Write-DetectionLog "Required file not found: $file" -Level "Error"
            $filesExist = $false
            continue
        }
        
        try {
            # Try to read the file to verify permissions
            $null = Get-Content $file -First 1 -ErrorAction Stop
            Write-DetectionLog "File exists and is accessible: $file"
        } catch {
            Write-DetectionLog "File exists but is not accessible: $file - $_" -Level "Error"
            $filesExist = $false
        }
    }

    # Check if scheduled task exists and is properly configured
    $taskExists = $false
    try {
        $task = Get-ScheduledTask -TaskName $taskName -ErrorAction Stop
        Write-DetectionLog "Task found with state: $($task.State)"
        
        if ($task.State -eq "Ready" -or $task.State -eq "Running") {
            Write-DetectionLog "Scheduled task exists and is in valid state: $taskName"
            $taskExists = $true
        } else {
            Write-DetectionLog "Scheduled task exists but is in invalid state: $($task.State)" -Level "Error"
        }
    } catch {
        Write-DetectionLog "Scheduled task check failed: $_" -Level "Error"
    }

    # Check directory permissions
    $permissionsValid = $false
    try {
        $acl = Get-Acl $installRoot
        
        # Check SYSTEM permissions
        $systemSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-18")
        $systemHasFullControl = $acl.Access | Where-Object { 
            $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]) -eq $systemSid -and 
            $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::FullControl 
        }

        # Check Users group permissions
        $usersSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-545")
        $usersHasReadExecute = $acl.Access | Where-Object { 
            $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]) -eq $usersSid -and 
            $_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::ReadAndExecute 
        }

        if ($systemHasFullControl -and $usersHasReadExecute) {
            Write-DetectionLog "Directory permissions are correctly set"
            $permissionsValid = $true
        } else {
            Write-DetectionLog "Directory permissions are not correctly set. SYSTEM FullControl: $($null -ne $systemHasFullControl), Users ReadExecute: $($null -ne $usersHasReadExecute)" -Level "Error"
        }
    } catch {
        Write-DetectionLog "Failed to check directory permissions: $_" -Level "Error"
    }

    # Return overall status
    $result = $filesExist -and $taskExists -and $permissionsValid
    Write-DetectionLog "Component check results - Files: $filesExist, Task: $taskExists, Permissions: $permissionsValid"
    return $result
}

try {
    Write-DetectionLog "Starting detection check..."
    Write-DetectionLog "Script running as user: $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    
    # Check if running with admin rights
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-DetectionLog "Running with admin rights: $isAdmin"

    # Try detection up to 3 times with a 10-second delay between attempts
    $maxAttempts = 3
    $currentAttempt = 1
    $success = $false

    while ($currentAttempt -le $maxAttempts -and -not $success) {
        Write-DetectionLog "Detection attempt $currentAttempt of $maxAttempts"
        
        $success = Test-Components
        
        if (-not $success -and $currentAttempt -lt $maxAttempts) {
            Write-DetectionLog "Detection failed, waiting 10 seconds before retry..."
            Start-Sleep -Seconds 10
            $currentAttempt++
        }
    }

    if ($success) {
        Write-DetectionLog "All components detected successfully"
        exit 0
    } else {
        Write-DetectionLog "Detection failed after $maxAttempts attempts" -Level "Error"
        exit 1
    }
} catch {
    Write-DetectionLog "Detection script failed: $_" -Level "Error"
    exit 1
}
