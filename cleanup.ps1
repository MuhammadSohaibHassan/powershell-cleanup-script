# Function to write colored output
function Write-Color {
    param (
        [string]$message,
        [System.ConsoleColor]$color = [System.ConsoleColor]::White
    )
    Write-Host $message -ForegroundColor $color
}

# Function to wait for service to start with a timeout
function Wait-ForService {
    param (
        [string]$serviceName,
        [int]$timeoutSeconds = 30
    )

    $elapsedTime = 0
    while ($elapsedTime -lt $timeoutSeconds) {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service.Status -eq 'Running') {
            Write-Color "Service '$serviceName' started successfully." Green
            return $true
        }
        Start-Sleep -Seconds 1
        $elapsedTime++
    }

    Write-Color "Timed out waiting for service '$serviceName' to start." Red
    return $false
}

# Function to clear temporary files
function Clear-TempFiles {
    Write-Color "Starting to clear temporary files..." Cyan
    $tempPaths = @(
        "$env:temp\*",
        "$env:SystemRoot\Temp\*"
    )
    foreach ($path in $tempPaths) {
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-Color "Cleared temporary files from: $path" Green
        } catch {
            Write-Color "Skipped inaccessible files in: $path" Yellow
        }
    }
    Write-Color "Temporary file cleanup complete." Green
}

# Function to clear prefetch files
function Clear-Prefetch {
    Write-Color "Starting to clear prefetch files..." Cyan
    $prefetchPath = "$env:SystemRoot\Prefetch\*"
    try {
        Remove-Item -Path $prefetchPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Color "Prefetch files cleared." Green
    } catch {
        Write-Color "Skipped inaccessible prefetch files." Yellow
    }
    Write-Color "Prefetch file cleanup complete." Green
}

# Function to delete Windows Update Cache
function Clear-WindowsUpdateCache {
    Write-Color "Starting to clear Windows Update cache..." Cyan
    try {
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Stop-Service -Name bits -Force -ErrorAction SilentlyContinue

        $updateCachePath = "C:\Windows\SoftwareDistribution\*"
        Remove-Item -Path $updateCachePath -Recurse -Force -ErrorAction SilentlyContinue

        # Wait for services to restart
        if (Wait-ForService -serviceName 'wuauserv') {
            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        }
        if (Wait-ForService -serviceName 'bits') {
            Start-Service -Name bits -ErrorAction SilentlyContinue
        }
        Write-Color "Windows Update cache cleared." Green
    } catch {
        Write-Color "Failed to clear Windows Update cache. Check for any service-related issues." Red
    }
}

# Function to run Disk Cleanup without requiring user clicks
function Run-DiskCleanup {
    Write-Color "Starting Disk Cleanup process..." Cyan
    try {
        # Run Disk Cleanup configuration silently
        $cleanmgrArgs = "/sageset:1 /D C:"  # Set to clean drive C: (change if needed)
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList $cleanmgrArgs -Wait -ErrorAction SilentlyContinue

        # Run Disk Cleanup silently without manual confirmation
        $cleanmgrArgs = "/sagerun:1"
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList $cleanmgrArgs -Wait -ErrorAction SilentlyContinue

        Write-Color "Disk Cleanup completed successfully." Green
    } catch {
        Write-Color "Disk Cleanup encountered an issue. Please check your system settings." Red
    }
}

# Main script execution
Write-Color "Beginning system cleanup..." Green

# Step 1: Clear temporary and prefetch files
Clear-TempFiles
Clear-Prefetch

# Step 2: Run Disk Cleanup
Run-DiskCleanup

# Step 3: Clear Windows Update Cache
Clear-WindowsUpdateCache

Write-Color "System cleanup process completed successfully!" Green
