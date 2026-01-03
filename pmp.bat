<# :
@echo off
setlocal DisableDelayedExpansion
title Smart Gamer Setup
set "menu=%~f0"

:: Stable Admin Check
fsutil dirty query %systemdrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:: Run PowerShell directly from this file
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((Get-Content -LiteralPath '%menu%') -join \"`n\")"
echo.
pause
exit /b
#>

# 1. YOUR BANNER
$ascii = @"
_________________________________________________     _________________     __________________________________________     ______________
7     77  _  77     77     77  _  77  _  77     7     7        77  7  7     7     77  _  77        77  77     77     7     7     77     7
|  -  ||    _||  ___!|  -  ||  _  ||    _||  ___!     |  _  _  ||  !  |     |    __!|  _  ||  _  _  ||  ||  _  ||    __!     |  -  ||  ___!
|  ___!|  _ \ |  __|_|  ___!|  7  ||  _ \ |  __|_     |  7  7  |!_   _!     |  !  7|  7  ||  7  7  ||  ||  7  ||  !  7     |  ___!|  7___
|  7   |  7  ||     7|  7   |  |  ||  7  ||     7     |  |  |  | 7   7      |     ||  |  ||  |  |  ||  ||  |  ||     |     |  7   |     7
!__!   !__!__!!_____!!__!   !__!__!!__!__!!_____!     !__!__!__! !___!      !_____!!__!__!!__!__!__!!__!!__!__!!_____!     !__!   !_____!
"@
Clear-Host
Write-Host $ascii -ForegroundColor Cyan
Write-Host "`nReady to optimize? Press ENTER to open the menu..." -ForegroundColor Yellow
$null = Read-Host

# 2. APP LIST (New Apps Added)
Add-Type -AssemblyName System.Windows.Forms
$appList = @(
    @{ Name = "Roblox"; ID = "Roblox.Roblox" },
    @{ Name = "SKLauncher"; ID = "S-K-Group.SKLauncher" },
    @{ Name = "Medal"; ID = "Medal.Medal" },
    @{ Name = "Steam"; ID = "Valve.Steam" },
    @{ Name = "Discord"; ID = "Discord.Discord" },
    @{ Name = "Twitch"; ID = "Twitch.Twitch" },
    @{ Name = "OBS Studio"; ID = "OBSProject.OBSStudio" },
    @{ Name = "Lunar Client"; ID = "Moonsworth.LunarClient" },
    @{ Name = "EA App"; ID = "ElectronicArts.EADesktop" },
    @{ Name = "Epic Games Launcher"; ID = "EpicGames.EpicGamesLauncher" },
    @{ Name = "Modrinth App"; ID = "Modrinth.ModrinthApp" },
    @{ Name = "CurseForge"; ID = "Overwolf.CurseForge" },
    @{ Name = "7-Zip"; ID = "7zip.7zip" },
    @{ Name = "Google Chrome"; ID = "Google.Chrome" },
    @{ Name = "VLC Media Player"; ID = "VideoLAN.VLC" },
    @{ Name = "Notepad++"; ID = "Notepad++.Notepad++" },
    @{ Name = "Stremio"; ID = "Stremio.Stremio" },
    @{ Name = "WhatsApp"; ID = "9NKSQGP7F2NH" },
    @{ Name = "Spotify"; ID = "Spotify.Spotify" },
    @{ Name = "VS Code"; ID = "Microsoft.VisualStudioCode" },
    @{ Name = "MSI Afterburner"; ID = "MSI.Afterburner" }
)

# 3. GUI SELECTION
$form = New-Object System.Windows.Forms.Form
$form.Text = "App Setup"; $form.Size = "350,650"; $form.StartPosition = "CenterScreen"; $form.Topmost = $true

$clb = New-Object System.Windows.Forms.CheckedListBox
$clb.Location = "15, 20"; $clb.Size = "300, 480"; $clb.CheckOnClick = $true
$appList | ForEach-Object { [void]$clb.Items.Add($_.Name) }
$form.Controls.Add($clb)

$btn = New-Object System.Windows.Forms.Button
$btn.Text = "START"; $btn.Location = "15, 520"; $btn.Size = "300, 40"; $btn.DialogResult = "OK"
$form.Controls.Add($btn)

# 4. INSTALL LOGIC
if ($form.ShowDialog() -eq "OK") {
    Write-Host "`n--- STEP 1: UPDATING DRIVERS ---" -ForegroundColor Yellow
    try {
        $Searcher = (New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher()
        $Searcher.ServiceID = '7971f918-a847-4430-9279-4a52d1efe18d'
        $Drivers = $Searcher.Search("IsInstalled=0 and Type='Driver'").Updates
        if ($Drivers.Count -gt 0) {
            Write-Host "Installing updates..." -ForegroundColor Cyan
            $Downloader = (New-Object -Com Microsoft.Update.Session).CreateUpdateDownloader(); $Downloader.Updates = $Drivers; $null = $Downloader.Download()
            $Installer = (New-Object -Com Microsoft.Update.Session).CreateUpdateInstaller(); $Installer.Updates = $Drivers; $null = $Installer.Install()
        }
    } catch { Write-Host "Driver service busy." -ForegroundColor Gray }

    Write-Host "`n--- STEP 2: INSTALLING APPS ---" -ForegroundColor Yellow
    $installed = (winget list --accept-source-agreements).Name
    foreach ($item in $clb.CheckedItems) {
        $app = $appList | Where-Object { $_.Name -eq $item }
        if ($installed -contains $app.Name) {
            Write-Host "[-] Skipping: $($app.Name) (Already Installed)" -ForegroundColor Gray
        } else {
            Write-Host "[+] Installing: $($app.Name)..." -ForegroundColor Cyan
            winget install --id $app.ID --silent --accept-package-agreements --accept-source-agreements
        }
    }
    
    Start-Process "https://www.youtube.com/@Theneqmc"
    Write-Host "`nAll done! Enjoy your clean setup." -ForegroundColor Green
}