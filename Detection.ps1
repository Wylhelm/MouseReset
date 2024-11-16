# Simplified detection script for Mouse Reset Solution
$ErrorActionPreference = "SilentlyContinue"

# Check if main script exists
$scriptPath = Join-Path $env:ProgramData "PNG\Scripts\Mouse\mouse.ps1"
$scriptExists = Test-Path $scriptPath -PathType Leaf

# Check if scheduled task exists and is enabled
$taskName = "mouse_reset"
$taskExists = $false
try {
    $task = Get-ScheduledTask -TaskName $taskName
    $validStates = @("Ready", "Running", "Standby", "Waiting")
    $taskExists = $validStates -contains $task.State
} catch {
    $taskExists = $false
}

# Return success only if both conditions are met
if ($scriptExists -and $taskExists) {
    exit 0
} else {
    exit 1
}
