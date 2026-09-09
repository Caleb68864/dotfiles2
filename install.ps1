#Requires -Version 7.0
<#
.SYNOPSIS
    Deploy this dotfiles repo's Neovim config on native Windows.

.DESCRIPTION
    The Linux side of this repo uses GNU Stow to symlink configs into place.
    Stow does not exist on Windows, and Windows Neovim reads its config from
    %LOCALAPPDATA%\nvim rather than ~/.config/nvim, so this script does the
    equivalent job: link the config, then install the external tools.

    The config is linked with a DIRECTORY JUNCTION, not a symbolic link. Neovim
    follows both transparently, but a symlink needs EITHER Developer Mode or an
    elevated shell, while a junction needs neither -- so this script runs from
    an ordinary prompt on a stock machine, and there is no permission preflight
    to fail. The one constraint a junction adds is that its target must be a
    local absolute path (no UNC path, no mapped network drive), which holds for
    any ordinary clone of this repo.
#>

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
$NvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$NvimSource = Join-Path $RepoRoot "nvim"

# --- Preflight ---------------------------------------------------------------
#
# There is no permission check here on purpose: see the note at the top of this
# file. A junction needs neither Developer Mode nor elevation, so the only thing
# that has to be true before starting is that scoop exists.

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop is not installed. Install it first with:" -ForegroundColor Red
    Write-Host "  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
    Write-Host "  Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression"
    exit 1
}

# --- Link the Neovim config --------------------------------------------------
#
# Linking the config is what this script exists to do, so it happens FIRST.
# Both of the steps below it can abort the whole script under
# $ErrorActionPreference = "Stop" -- a package that fails to install, or a
# missing fonts/ directory --
# and if the link came last, that abort would leave the machine with new tools
# and no config. Ordered this way, a later failure still leaves a working
# Neovim and you can re-run to pick up the rest.

if (Test-Path $NvimTarget) {
    $backup = "$NvimTarget.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "Existing config found. Moving it to $backup" -ForegroundColor Yellow
    Move-Item -Path $NvimTarget -Destination $backup
}

Write-Host "Linking $NvimTarget -> $NvimSource" -ForegroundColor Cyan
New-Item -ItemType Junction -Path $NvimTarget -Target $NvimSource | Out-Null

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
# pwsh    - PowerShell 7. NOT optional either, and specifically the scoop copy.
#           options.lua points 'shell' at pwsh when it can find one and falls
#           back to Windows PowerShell 5.1 when it cannot, and 5.1 cannot parse
#           `&&` -- which is what telescope-fzf-native's Windows build command
#           uses, so on 5.1 that build fails and Telescope silently drops to
#           slow pure-Lua matching. Installing pwsh from the Microsoft Store or
#           `winget install Microsoft.PowerShell` does NOT fix this: those put
#           an App Execution Alias in WindowsApps, a zero-byte reparse point
#           that `vim.fn.executable("pwsh")` reports as absent, so Neovim never
#           sees it however well it works from a prompt. scoop lays down a real
#           executable, which Neovim does find.
# netcoredbg - the C# debug adapter dap.lua names. Without it :checkhealth
#           reports the coreclr adapter's `command` as not executable. Nothing
#           breaks at startup, because the adapter is only built on first use,
#           so this is only needed if you actually debug C# on this machine.

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
scoop install neovim neovide zig ripgrep fd cmake git gh lazygit yazi fzf pwsh netcoredbg

# --- Fonts -------------------------------------------------------------------
#
# Fonts are installed PER-USER (into %LOCALAPPDATA%\Microsoft\Windows\Fonts
# plus an HKCU registry entry) instead of system-wide (%WINDIR%\Fonts). Nothing
# else in this script needs elevation -- the junction above deliberately removed
# the last thing that did -- so the normal way to run it is from an ordinary
# prompt. Writing to the system font folder needs elevation; from a normal
# prompt the old Shell.Application CopyHere() call would either silently no-op
# (COM does not throw, so $ErrorActionPreference can't catch it) or pop an
# unexpected UAC prompt mid-script. The per-user location needs no elevation at
# all, so it behaves the same however the script was launched.

Write-Host "Installing JetBrainsMono Nerd Font..." -ForegroundColor Cyan
$fontDir = Join-Path $RepoRoot "fonts"
$userFontDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"

if (-not (Test-Path $fontDir)) {
    # Get-ChildItem on a missing directory is a terminating error under
    # $ErrorActionPreference = "Stop", which would kill the rest of the
    # script. Missing fonts are not worth that, so say so and carry on.
    Write-Host "  No fonts/ directory in the repo -- skipping fonts." -ForegroundColor Yellow
} else {
    New-Item -ItemType Directory -Path $userFontDir -Force | Out-Null

    $fontRegKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
    if (-not (Test-Path $fontRegKey)) {
        New-Item -Path $fontRegKey -Force | Out-Null
    }

    Add-Type -AssemblyName System.Drawing

    Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
        $destPath = Join-Path $userFontDir $_.Name

        # -Force overwrites a stale copy from a previous run rather than erroring,
        # which is what makes re-running this installer safe.
        Copy-Item -Path $_.FullName -Destination $destPath -Force

        # The family name is read out of the font file itself, so the entry
        # matches what Windows will call the font rather than the .ttf filename.
        $collection = New-Object System.Drawing.Text.PrivateFontCollection
        $collection.AddFontFile($destPath)
        $familyName = $collection.Families[0].Name
        $collection.Dispose()

        # The family is NOT enough on its own. Regular, Bold, Italic and
        # BoldItalic all report the SAME family ("JetBrainsMono Nerd Font"), so a
        # family-named registry value means every face overwrites the previous
        # one: 46 font files collapse into about 12 registrations, and bold and
        # italic end up unregistered and synthesized by the renderer.
        #
        # Each value name therefore needs the FACE, e.g.
        # "JetBrainsMono Nerd Font Bold (TrueType)". System.Drawing does not
        # expose the face name, so the weight/slant comes from the part of the
        # filename after the hyphen ("-ExtraBoldItalic"), split back into words.
        # Combined with the family (which does differ between the base, Mono and
        # Propo variants) that gives one distinct value name per file.
        $style = ""
        if ($_.BaseName -match '-(.+)$') {
            $style = ($matches[1] -creplace '(?<!^)(?=[A-Z])', ' ')
        }
        # "Regular" is the unmarked face; Windows names it by the family alone.
        if ($style -eq "Regular") { $style = "" }
        $faceName = if ($style) { "$familyName $style" } else { $familyName }

        # Per-user font registrations store the FULL FILE PATH as the value.
        # (System-wide registrations can get away with just a filename, because
        # Windows already knows to look in %WINDIR%\Fonts -- that shortcut does
        # not apply here.) Set-ItemProperty overwrites an existing value of the
        # same name, so re-running this script does not create duplicate entries.
        $valueName = "$faceName (TrueType)"
        Set-ItemProperty -Path $fontRegKey -Name $valueName -Value $destPath -Type String -Force
    }
}

# --- Done --------------------------------------------------------------------

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  1. Run: nvim --headless `"+Lazy! sync`" +qa"
Write-Host "  2. Run: nvim --headless `"+checkhealth`" +qa   (review any ERRORs)"
Write-Host "  3. Launch the GUI with: neovide"
