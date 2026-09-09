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
scoop bucket add extras 2>$null
scoop install neovim neovide zig ripgrep fd cmake git gh lazygit yazi fzf

# --- Fonts -------------------------------------------------------------------

Write-Host "Installing JetBrainsMono Nerd Font..." -ForegroundColor Cyan
$fontDir = Join-Path $RepoRoot "fonts"
$shell = New-Object -ComObject Shell.Application
$fonts = $shell.Namespace(0x14)
Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
    $installed = Join-Path $env:WINDIR "Fonts\$($_.Name)"
    if (-not (Test-Path $installed)) {
        $fonts.CopyHere($_.FullName, 0x10)
    }
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
