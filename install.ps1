#Requires -Version 7.0
<#
.SYNOPSIS
    Deploy this dotfiles repo's Neovim config on native Windows.

.DESCRIPTION
    The Linux side of this repo uses GNU Stow to symlink configs into place.
    Stow does not exist on Windows, and Windows Neovim reads its config from
    %LOCALAPPDATA%\nvim rather than ~/.config/nvim, so this script does the
    equivalent job: install the external tools, then link the config.

    Creating a symlink on Windows requires EITHER Developer Mode to be enabled
    OR an elevated shell. This script checks up front and tells you which is
    missing, rather than failing later with an opaque access-denied error.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$NvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$NvimSource = Join-Path $RepoRoot "nvim"

function Test-CanSymlink {
    # Developer Mode lets a non-elevated process create symlinks.
    $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $devMode = (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1

    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $elevated = ([Security.Principal.WindowsPrincipal]$identity).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)

    return @{ DevMode = $devMode; Elevated = $elevated; Ok = ($devMode -or $elevated) }
}

# --- Preflight ---------------------------------------------------------------

$symlink = Test-CanSymlink
if (-not $symlink.Ok) {
    Write-Host "Cannot create symlinks." -ForegroundColor Red
    Write-Host "Fix ONE of these, then re-run:"
    Write-Host "  1. Enable Developer Mode:  Settings > System > For developers > Developer Mode"
    Write-Host "  2. Or re-run this script from an Administrator PowerShell"
    exit 1
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop is not installed. Install it first with:" -ForegroundColor Red
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Host "  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
    exit 1
}

# --- External tools ----------------------------------------------------------
#
# neovim  - the editor itself
# neovide - the GUI front end; the whole point of the Windows setup
# zig     - a C compiler for treesitter. NOT optional: auto_install is on, so
#           without a compiler every new filetype throws an error popup.
# ripgrep - Telescope's grep backend
# fd      - Telescope's file finder backend
# cmake   - needed to build telescope-fzf-native on Windows (there is no make)
# lazygit - git TUI (the nvim plugin is skipped if this is absent)
# yazi    - file manager (likewise)

Write-Host "Installing tools via scoop..." -ForegroundColor Cyan

# `scoop bucket add` exits nonzero when the bucket is already registered --
# which is the normal case on every run after the first. On PowerShell 7.4+,
# $PSNativeCommandUseErrorActionPreference defaults to $true, so a nonzero
# exit from a native command (scoop included) is promoted into a terminating
# error, and $ErrorActionPreference = "Stop" up top would then kill this
# script before a single package installs -- on the most ordinary re-run
# there is. try/catch swallows that one expected failure so re-running the
# installer stays safe. (`scoop install` below is deliberately left
# unguarded: a real package-install failure SHOULD stop the script.)
try {
    scoop bucket add extras
} catch {
    Write-Host "  (extras bucket already added)" -ForegroundColor DarkGray
}
scoop install neovim neovide zig ripgrep fd cmake git gh lazygit yazi fzf

# --- Fonts -------------------------------------------------------------------
#
# Fonts are installed PER-USER (into %LOCALAPPDATA%\Microsoft\Windows\Fonts
# plus an HKCU registry entry) instead of system-wide (%WINDIR%\Fonts). The
# preflight above accepts EITHER Developer Mode OR elevation -- so a user can
# legitimately reach this point in a non-elevated shell. Writing to the
# system font folder needs elevation; on that non-elevated path the old
# Shell.Application CopyHere() call would either silently no-op (COM does not
# throw, so $ErrorActionPreference can't catch it) or pop an unexpected UAC
# prompt mid-script. The per-user location needs no elevation at all, so it
# behaves identically on both preflight branches.

Write-Host "Installing JetBrainsMono Nerd Font..." -ForegroundColor Cyan
$fontDir = Join-Path $RepoRoot "fonts"
$userFontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
New-Item -ItemType Directory -Path $userFontDir -Force | Out-Null

$fontRegKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
if (-not (Test-Path $fontRegKey)) {
    New-Item -Path $fontRegKey -Force | Out-Null
}

# Reading the real font-family name out of each file (rather than guessing it
# from the filename) is required because the registry value's NAME has to
# match what Windows will display as the font name, not the .ttf's filename.
Add-Type -AssemblyName System.Drawing

Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
    $destPath = Join-Path $userFontDir $_.Name

    # -Force overwrites a stale copy from a previous run rather than erroring,
    # which is what makes re-running this installer safe.
    Copy-Item -Path $_.FullName -Destination $destPath -Force

    $collection = New-Object System.Drawing.Text.PrivateFontCollection
    $collection.AddFontFile($destPath)
    $familyName = $collection.Families[0].Name
    $collection.Dispose()

    # Per-user font registrations store the FULL FILE PATH as the value.
    # (System-wide registrations can get away with just a filename, because
    # Windows already knows to look in %WINDIR%\Fonts -- that shortcut does
    # not apply here.) Set-ItemProperty overwrites an existing value of the
    # same name, so re-running this script does not create duplicate entries.
    $valueName = "$familyName (TrueType)"
    Set-ItemProperty -Path $fontRegKey -Name $valueName -Value $destPath -Type String -Force
}

# --- Link the Neovim config --------------------------------------------------

if (Test-Path $NvimTarget) {
    $backup = "$NvimTarget.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Existing config found. Moving it to $backup" -ForegroundColor Yellow
    Move-Item -Path $NvimTarget -Destination $backup
}

Write-Host "Linking $NvimTarget -> $NvimSource" -ForegroundColor Cyan
New-Item -ItemType SymbolicLink -Path $NvimTarget -Target $NvimSource | Out-Null

# --- Done --------------------------------------------------------------------

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  1. Run: nvim --headless `"+Lazy! sync`" +qa"
Write-Host "  2. Run: nvim --headless `"+checkhealth`" +qa   (review any ERRORs)"
Write-Host "  3. Launch the GUI with: neovide"
