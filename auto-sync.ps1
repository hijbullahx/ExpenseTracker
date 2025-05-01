# auto-sync.ps1
Write-Host "Starting auto-sync for ExpenseTracker..."

$folder = Get-Location
$filter = "*.*" # Monitor all files
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $folder
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.Filter = $filter

$lastCommitTime = Get-Date
$debounceSeconds = 60 # Wait 60 seconds to batch changes

$action = {
    $global:lastChangeTime = Get-Date
}

Register-ObjectEvent $watcher "Created" -Action $action
Register-ObjectEvent $watcher "Changed" -Action $action
Register-ObjectEvent $watcher "Deleted" -Action $action
Register-ObjectEvent $watcher "Renamed" -Action $action

Write-Host "Monitoring for changes. Press Ctrl+C to stop."

try {
    while ($true) {
        Start-Sleep -Seconds 5
        if ($global:lastChangeTime -and ((Get-Date) - $global:lastChangeTime).TotalSeconds -lt $debounceSeconds) {
            if (((Get-Date) - $lastCommitTime).TotalSeconds -ge $debounceSeconds) {
                Write-Host "Changes detected, committing and pushing..."
                git add .
                git commit -m "Auto-commit: Updated files at $(Get-Date)" --quiet
                git push origin master --quiet
                $lastCommitTime = Get-Date
                Write-Host "Changes committed and pushed to GitHub"
            }
        }
    }
}
finally {
    $watcher.EnableRaisingEvents = $false
    $watcher.Dispose()
    Write-Host "Stopped monitoring."
}