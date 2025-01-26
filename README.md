# PowerShell System Cleanup Script

This repository contains a PowerShell script designed to perform system cleanup tasks, including:

- Clearing temporary files from system and user directories.
- Clearing prefetch files to improve system performance.
- Clearing Windows Update cache to free up space.
- Running Disk Cleanup silently without user intervention.

## Features

- **Clear Temporary Files**: Removes files from temporary directories to free up space.
- **Clear Prefetch Files**: Cleans up prefetch files that may not be needed anymore.
- **Clear Windows Update Cache**: Deletes the Windows Update cache, which can take up significant space.
- **Run Disk Cleanup**: Runs Disk Cleanup silently on the C: drive (can be adjusted to other drives).

## How to Use

To run the script directly from GitHub using PowerShell, execute the following command in your PowerShell terminal:

```powershell
irm "https://raw.githubusercontent.com/MuhammadSohaibHassan/powershell-cleanup-script/main/cleanup.ps1" | iex

