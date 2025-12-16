<#
.SYNOPSIS
    Install essential terminal utilities for Windows with comprehensive fallback strategies
.DESCRIPTION
    This script installs development tools and terminal utilities using multiple methods:
    1. WinGet (Microsoft's package manager) - Primary method
    2. GitHub Releases - Direct from GitHub
    3. Direct Downloads - From official websites
    4. Chocolatey - Alternative package manager
.PARAMETER DownloadPath
    Custom installation directory for downloaded files
.PARAMETER Method
    Choose specific installation method (WinGet, GitHub, Direct, Chocolatey, All)
.PARAMETER SkipWinget
    Skip WinGet, use fallbacks only
.PARAMETER FallbackOnly
    Skip WinGet entirely and use fallback methods
.PARAMETER ForceDownload
    Keep downloaded archives after installation
.PARAMETER MaxConcurrentDownloads
    Maximum number of concurrent downloads (default: 3)
.PARAMETER Tools
    Specific tools to install (comma-separated)
.PARAMETER SkipTools
    Tools to skip (comma-separated)
.PARAMETER Force
    Force reinstallation of existing tools
.PARAMETER LogPath
    Path to save log file
.PARAMETER ExportResults
    Export installation results to JSON file
.PARAMETER Category
    Install tools from specific categories only
.EXAMPLE
    .\DevTools.ps1
    Install all tools using default method (WinGet with fallbacks)
.EXAMPLE
    .\DevTools.ps1 -Category "Git,Productivity"
    Install tools from specific categories only
.EXAMPLE
    .\DevTools.ps1 -Method GitHub -Tools "git,neovim,starship" -DownloadPath "C:\Tools"
    Install specific tools using GitHub Releases method
.EXAMPLE
    .\DevTools.ps1 -WhatIf -FallbackOnly
    Dry run showing what would be installed without WinGet
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$DownloadPath = "$env:USERPROFILE\Downloads\DevTools",

    [Parameter()]
    [ValidateSet('WinGet', 'GitHub', 'Direct', 'Chocolatey', 'All')]
    [string]$Method = 'All',

    [Parameter()]
    [switch]$SkipWinget,

    [Parameter()]
    [switch]$FallbackOnly,

    [Parameter()]
    [switch]$ForceDownload,

    [Parameter()]
    [ValidateRange(1, 10)]
    [int]$MaxConcurrentDownloads = 3,

    [Parameter()]
    [string[]]$Tools,

    [Parameter()]
    [string[]]$SkipTools,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [string]$LogPath = "$env:TEMP\DevTools-$(Get-Date -Format 'yyyyMMdd-HHmmss').log",

    [Parameter()]
    [string]$ExportResults,

    [Parameter()]
    [ValidateSet('Git', 'Platform', 'Productivity', 'System', 'Terminal', 'Prompt', 'UI', 'Network', 'Multimedia', 'All')]
    [string[]]$Category = @('All')
)

#Requires -Version 7.0
Set-StrictMode -Version 3.0

# ============================================================================
# CONFIGURATION AND GLOBALS
# ============================================================================

# Global variables
$global:InstallationResults = @()
$global:FailedInstallations = @()
$global:ScriptStartTime = Get-Date
$global:IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Color definitions for output
$global:Colors = @{
    Success = 'Green'
    Error = 'Red'
    Warning = 'Yellow'
    Info = 'Cyan'
    Verbose = 'Gray'
}

# Tool definitions with categories and multiple installation methods
$global:ToolDefinitions = @{
    # ==================== Git and Development Tools ====================
    'git' = @{
        Name = 'Git for Windows'
        Category = 'Git'
        WinGetId = 'Git.Git'
        ChocolateyId = 'git'
        GitHubRepo = 'git-for-windows/git'
        DirectUrl = 'https://git-scm.com/download/win'
        InstallerType = 'exe'
        SilentArgs = '/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS'
        InstallCheck = { Get-Command git -ErrorAction SilentlyContinue }
        PostInstall = {
            # Configure git defaults
            git config --global core.autocrlf false
            git config --global core.safecrlf true
            git config --global pull.rebase false
        }
    }
    'lazygit' = @{
        Name = 'lazygit'
        Category = 'Git'
        WinGetId = 'jesseduffield.lazygit'
        ChocolateyId = 'lazygit'
        GitHubRepo = 'jesseduffield/lazygit'
        InstallerType = 'zip'
        BinaryName = 'lazygit.exe'
        InstallCheck = { Get-Command lazygit -ErrorAction SilentlyContinue }
    }
    'gh' = @{
        Name = 'GitHub CLI'
        Category = 'Git'
        WinGetId = 'GitHub.cli'
        ChocolateyId = 'gh'
        GitHubRepo = 'cli/cli'
        InstallerType = 'msi'
        SilentArgs = '/quiet'
        InstallCheck = { Get-Command gh -ErrorAction SilentlyContinue }
        PostInstall = {
            # Authenticate with GitHub
            Write-Host "To authenticate GitHub CLI, run: gh auth login" -ForegroundColor Yellow
        }
    }
    'neovim' = @{
        Name = 'Neovim'
        Category = 'Git'
        WinGetId = 'Neovim.Neovim'
        ChocolateyId = 'neovim'
        GitHubRepo = 'neovim/neovim'
        InstallerType = 'zip'
        BinaryName = 'nvim.exe'
        InstallCheck = { Get-Command nvim -ErrorAction SilentlyContinue }
        PostInstall = {
            # Create Neovim config directory if it doesn't exist
            $nvimDir = "$env:LOCALAPPDATA\nvim"
            if (-not (Test-Path $nvimDir)) {
                New-Item -ItemType Directory -Path $nvimDir -Force | Out-Null
            }
        }
    }
    'vale' = @{
        Name = 'Vale'
        Category = 'Git'
        WinGetId = 'errata-ai.vale'
        ChocolateyId = 'vale'
        GitHubRepo = 'errata-ai/vale'
        InstallerType = 'zip'
        BinaryName = 'vale.exe'
        InstallCheck = { Get-Command vale -ErrorAction SilentlyContinue }
    }
    'rust' = @{
        Name = 'Rust'
        Category = 'Git'
        WinGetId = 'Rustlang.Rust.GNU'
        ChocolateyId = 'rust'
        DirectUrl = 'https://static.rust-lang.org/rustup/dist/i686-pc-windows-gnu/rustup-init.exe'
        InstallerType = 'exe'
        SilentArgs = '-y'
        InstallCheck = { Get-Command cargo -ErrorAction SilentlyContinue }
    }
    'go' = @{
        Name = 'Go'
        Category = 'Git'
        WinGetId = 'GoLang.Go'
        ChocolateyId = 'golang'
        DirectUrl = 'https://golang.org/dl/'
        InstallerType = 'msi'
        SilentArgs = '/quiet'
        InstallCheck = { Get-Command go -ErrorAction SilentlyContinue }
        PostInstall = {
            # Set GOPATH if not already set
            if (-not $env:GOPATH) {
                $env:GOPATH = "$env:USERPROFILE\go"
                [Environment]::SetEnvironmentVariable('GOPATH', $env:GOPATH, 'User')
            }
        }
    }
    'task' = @{
        Name = 'Task'
        Category = 'Git'
        WinGetId = 'GoTask.Task'
        ChocolateyId = 'go-task'
        GitHubRepo = 'go-task/task'
        InstallerType = 'zip'
        BinaryName = 'task.exe'
        InstallCheck = { Get-Command task -ErrorAction SilentlyContinue }
    }

    # ==================== Platform and Language Tooling ====================
    'step' = @{
        Name = 'Smallstep CLI'
        Category = 'Platform'
        WinGetId = 'Smallstep.step'
        ChocolateyId = 'step'
        GitHubRepo = 'smallstep/cli'
        InstallerType = 'zip'
        BinaryName = 'step.exe'
        InstallCheck = { Get-Command step -ErrorAction SilentlyContinue }
    }
    'trivy' = @{
        Name = 'Trivy'
        Category = 'Platform'
        WinGetId = 'AquaSecurity.Trivy'
        ChocolateyId = 'trivy'
        GitHubRepo = 'aquasecurity/trivy'
        InstallerType = 'zip'
        BinaryName = 'trivy.exe'
        InstallCheck = { Get-Command trivy -ErrorAction SilentlyContinue }
    }
    'openssh' = @{
        Name = 'OpenSSH'
        Category = 'Platform'
        WinGetId = 'Microsoft.OpenSSH.Beta'
        ChocolateyId = 'openssh'
        DirectUrl = 'https://github.com/PowerShell/openssh-portable/releases/latest'
        InstallerType = 'msi'
        SilentArgs = '/quiet'
        InstallCheck = { Get-Command ssh -ErrorAction SilentlyContinue }
    }

    # ==================== Productivity and Navigation ====================
    'zoxide' = @{
        Name = 'zoxide'
        Category = 'Productivity'
        WinGetId = 'ajeetdsouza.zoxide'
        ChocolateyId = 'zoxide'
        GitHubRepo = 'ajeetdsouza/zoxide'
        InstallerType = 'zip'
        BinaryName = 'zoxide.exe'
        InstallCheck = { Get-Command zoxide -ErrorAction SilentlyContinue }
        PostInstall = {
            ## ===== Initialize zoxide for PowerShell ==========
            # Invoke-Expression (& {
            #     $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
            #     (zoxide init --hook $hook powershell | Out-String)
            # })
        }
    }
    'psfzf' = @{
        Name = 'PSFzf'
        Category = 'Productivity'
        PowerShellModule = 'PSFzf'
        InstallCheck = { Get-Module -ListAvailable -Name PSFzf }
        PostInstall = {
            # Import and configure PSFzf
            Import-Module PSFzf -ErrorAction SilentlyContinue
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        }
    }
    'psreadline' = @{
        Name = 'PSReadLine'
        Category = 'Productivity'
        PowerShellModule = 'PSReadLine'
        InstallCheck = { Get-Module -ListAvailable -Name PSReadLine }
        PostInstall = {
            # Configure PSReadLine
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -PredictionViewStyle ListView
            Set-PSReadLineOption -EditMode Windows
        }
    }
    'fd' = @{
        Name = 'fd'
        Category = 'Productivity'
        WinGetId = 'sharkdp.fd'
        ChocolateyId = 'fd'
        GitHubRepo = 'sharkdp/fd'
        InstallerType = 'zip'
        BinaryName = 'fd.exe'
        InstallCheck = { Get-Command fd -ErrorAction SilentlyContinue }
    }
    'ripgrep' = @{
        Name = 'ripgrep'
        Category = 'Productivity'
        WinGetId = 'BurntSushi.ripgrep.GNU'
        ChocolateyId = 'ripgrep'
        GitHubRepo = 'BurntSushi/ripgrep'
        InstallerType = 'zip'
        BinaryName = 'rg.exe'
        InstallCheck = { Get-Command rg -ErrorAction SilentlyContinue }
    }
    'bat' = @{
        Name = 'bat'
        Category = 'Productivity'
        WinGetId = 'sharkdp.bat'
        ChocolateyId = 'bat'
        GitHubRepo = 'sharkdp/bat'
        InstallerType = 'zip'
        BinaryName = 'bat.exe'
        InstallCheck = { Get-Command bat -ErrorAction SilentlyContinue }
    }
    'eza' = @{
        Name = 'eza'
        Category = 'Productivity'
        WinGetId = 'eza-community.eza'
        ChocolateyId = 'eza'
        GitHubRepo = 'eza-community/eza'
        InstallerType = 'zip'
        BinaryName = 'eza.exe'
        InstallCheck = { Get-Command eza -ErrorAction SilentlyContinue }
    }
    'delta' = @{
        Name = 'delta'
        Category = 'Productivity'
        WinGetId = 'dandavison.delta'
        ChocolateyId = 'delta'
        GitHubRepo = 'dandavison/delta'
        InstallerType = 'zip'
        BinaryName = 'delta.exe'
        InstallCheck = { Get-Command delta -ErrorAction SilentlyContinue }
    }
    'tre' = @{
        Name = 'tre'
        Category = 'Productivity'
        WinGetId = 'dduan.TRE'
        ChocolateyId = 'tre'
        GitHubRepo = 'dduan/tre'
        InstallerType = 'zip'
        BinaryName = 'tre.exe'
        InstallCheck = { Get-Command tre -ErrorAction SilentlyContinue }
    }
    'mise' = @{
        Name = 'mise'
        Category = 'Productivity'
        GitHubRepo = 'jdx/mise'
        InstallerType = 'ps1'
        InstallCheck = { Get-Command mise -ErrorAction SilentlyContinue }
        PostInstall = {
            # Initialize mise
            mise activate powershell | Out-String | Invoke-Expression
        }
    }

    # ==================== System Information and Utilities ====================
    'fastfetch' = @{
        Name = 'fastfetch'
        Category = 'System'
        WinGetId = 'fastfetch.cli'
        ChocolateyId = 'fastfetch'
        GitHubRepo = 'fastfetch-cli/fastfetch'
        InstallerType = 'zip'
        BinaryName = 'fastfetch.exe'
        InstallCheck = { Get-Command fastfetch -ErrorAction SilentlyContinue }
    }
    'btop' = @{
        Name = 'btop'
        Category = 'System'
        WinGetId = 'aristocratos.btop'
        ChocolateyId = 'btop'
        GitHubRepo = 'aristocratos/btop'
        InstallerType = 'zip'
        BinaryName = 'btop.exe'
        InstallCheck = { Get-Command btop -ErrorAction SilentlyContinue }
    }
    'tldr' = @{
        Name = 'tldr'
        Category = 'System'
        NodePackage = 'tldr'
        InstallCheck = { Get-Command tldr -ErrorAction SilentlyContinue }
    }
    'glow' = @{
        Name = 'glow'
        Category = 'System'
        WinGetId = 'charmbracelet.glow'
        ChocolateyId = 'glow'
        GitHubRepo = 'charmbracelet/glow'
        InstallerType = 'zip'
        BinaryName = 'glow.exe'
        InstallCheck = { Get-Command glow -ErrorAction SilentlyContinue }
    }
    'ag' = @{
        Name = 'The Silver Searcher'
        Category = 'System'
        ChocolateyId = 'ag'
        GitHubRepo = 'ggreer/the_silver_searcher'
        InstallerType = 'zip'
        BinaryName = 'ag.exe'
        InstallCheck = { Get-Command ag -ErrorAction SilentlyContinue }
    }

    # ==================== Terminal Emulators ====================
    'windows-terminal' = @{
        Name = 'Windows Terminal'
        Category = 'Terminal'
        WinGetId = 'Microsoft.WindowsTerminal'
        ChocolateyId = 'microsoft-windows-terminal'
        GitHubRepo = 'microsoft/terminal'
        InstallerType = 'msixbundle'
        InstallCheck = { Test-Path "$env:ProgramFiles\WindowsApps\Microsoft.WindowsTerminal*" }
        PostInstall = {
            # Create Windows Terminal settings directory if it doesn't exist
            $wtSettingsDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
            if (-not (Test-Path $wtSettingsDir)) {
                New-Item -ItemType Directory -Path $wtSettingsDir -Force | Out-Null
            }
        }
    }

    # ==================== Network and Web Tools ====================

    'globalping' = @{
        Name = 'Globalping'
        Category = 'Network'
        NodePackage = '@jsdelivr/globalping-cli'
        InstallCheck = { Get-Command globalping -ErrorAction SilentlyContinue }
    }
    'dog' = @{
        Name = 'dog'
        Category = 'Network'
        WinGetId = 'ogham.dog'
        ChocolateyId = 'dog'
        GitHubRepo = 'ogham/dog'
        InstallerType = 'zip'
        BinaryName = 'dog.exe'
        InstallCheck = { Get-Command dog -ErrorAction SilentlyContinue }
    }

    # ==================== Multimedia Editing ====================

    'auto-editor' = @{
        Name = 'Auto-Editor'
        Category = 'Multimedia'
        PythonPackage = 'auto-editor'
        InstallCheck = { Get-Command auto-editor -ErrorAction SilentlyContinue }
    }
    'imagemagick' = @{
        Name = 'ImageMagick'
        Category = 'Multimedia'
        WinGetId = 'ImageMagick.ImageMagick'
        ChocolateyId = 'imagemagick'
        DirectUrl = 'https://download.imagemagick.org/ImageMagick/download/binaries/'
        InstallerType = 'exe'
        SilentArgs = '/verysilent /suppressmsgboxes /mergetasks=""'
        InstallCheck = { Get-Command magick -ErrorAction SilentlyContinue }
    }
    'yt-dlp' = @{
        Name = 'yt-dlp'
        Category = 'Multimedia'
        WinGetId = 'yt-dlp.yt-dlp'
        ChocolateyId = 'yt-dlp'
        GitHubRepo = 'yt-dlp/yt-dlp'
        InstallerType = 'exe'
        BinaryName = 'yt-dlp.exe'
        InstallCheck = { Get-Command yt-dlp -ErrorAction SilentlyContinue }
    }

    # ==================== Essential Utilities ====================
    'curl' = @{
        Name = 'cURL'
        Category = 'System'
        WinGetId = 'cURL.cURL'
        ChocolateyId = 'curl'
        DirectUrl = 'https://curl.se/windows/'
        InstallerType = 'zip'
        BinaryName = 'curl.exe'
        InstallCheck = { Get-Command curl -ErrorAction SilentlyContinue }
    }
    'wget' = @{
        Name = 'Wget'
        Category = 'System'
        WinGetId = 'GnuWin32.Wget'
        ChocolateyId = 'wget'
        DirectUrl = 'https://eternallybored.org/misc/wget/'
        InstallerType = 'zip'
        BinaryName = 'wget.exe'
        InstallCheck = { Get-Command wget -ErrorAction SilentlyContinue }
    }
    '7zip' = @{
        Name = '7-Zip'
        Category = 'System'
        WinGetId = '7zip.7zip'
        ChocolateyId = '7zip'
        DirectUrl = 'https://www.7-zip.org/a/7z2401-x64.exe'
        InstallerType = 'exe'
        SilentArgs = '/S'
        InstallCheck = { Test-Path "$env:ProgramFiles\7-Zip\7z.exe" }
    }
    'nodejs' = @{
        Name = 'Node.js'
        Category = 'Platform'
        WinGetId = 'OpenJS.NodeJS'
        ChocolateyId = 'nodejs'
        DirectUrl = 'https://nodejs.org/dist/latest/'
        InstallerType = 'msi'
        SilentArgs = '/quiet'
        InstallCheck = { Get-Command node -ErrorAction SilentlyContinue }
        PostInstall = {
            # Update npm
            npm install -g npm@latest
        }
    }
    'python' = @{
        Name = 'Python'
        Category = 'Platform'
        WinGetId = 'Python.Python.3'
        ChocolateyId = 'python'
        DirectUrl = 'https://www.python.org/ftp/python/'
        InstallerType = 'exe'
        SilentArgs = '/quiet InstallAllUsers=1 PrependPath=1'
        InstallCheck = { Get-Command python -ErrorAction SilentlyContinue }
    }
    'fzf' = @{
        Name = 'fzf'
        Category = 'Productivity'
        WinGetId = 'junegunn.fzf'
        ChocolateyId = 'fzf'
        GitHubRepo = 'junegunn/fzf'
        InstallerType = 'zip'
        BinaryName = 'fzf.exe'
        InstallCheck = { Get-Command fzf -ErrorAction SilentlyContinue }
    }

    # ==================== Prompt and Theming ====================

    'posh-git' = @{
        Name = 'posh-git'
        Category = 'Prompt'
        PowerShellModule = 'posh-git'
        InstallCheck = { Get-Module -ListAvailable -Name posh-git }
        PostInstall = {
            # Import and configure posh-git
            Import-Module posh-git -ErrorAction SilentlyContinue
        }
    }
    'terminal-icons' = @{
        Name = 'Terminal-Icons'
        Category = 'Prompt'
        PowerShellModule = 'Terminal-Icons'
        InstallCheck = { Get-Module -ListAvailable -Name Terminal-Icons }
        PostInstall = {
            # Import and configure Terminal-Icons
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        }
    }
    'starship' = @{
        Name = 'Starship Prompt'
        Category = 'Prompt'
        WinGetId = 'Starship.Starship'
        ChocolateyId = 'starship'
        GitHubRepo = 'starship/starship'
        InstallerType = 'exe'
        SilentArgs = '--silent'
        InstallCheck = { Get-Command starship -ErrorAction SilentlyContinue }
        PostInstall = {
            # Initialize starship for PowerShell
            Invoke-Expression (&starship init powershell)

            # Create starship config if it doesn't exist
            $starshipConfig = "$env:USERPROFILE\.config\starship.toml"
            if (-not (Test-Path $starshipConfig)) {
                $configDir = Split-Path $starshipConfig -Parent
                if (-not (Test-Path $configDir)) {
                    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
                }
                @'
# Get project-specific configs from ~/.config/starship.d/*.toml
[aws]
disabled = true

[azure]
disabled = true

[battery]
full_symbol = "🔋"
charging_symbol = "⚡️"
discharging_symbol = "💀"

[container]
symbol = "📦"

[dart]
symbol = "🎯"

[directory]
truncation_length = 3
truncation_symbol = "…/"

[docker_context]
symbol = "🐳"

[elixir]
symbol = "💧"

[elm]
symbol = "🌳"

[gcloud]
symbol = "☁️"

[git_branch]
symbol = "🌱"

[golang]
symbol = "🐹"

[helm]
symbol = "⎈"

[java]
symbol = "☕"

[julia]
symbol = "ஃ"

[kotlin]
symbol = "🅺"

[nodejs]
symbol = "⬢"

[memory_usage]
disabled = false
threshold = -1
symbol = "🐏"
style = "bold dimmed white"

[nim]
symbol = "👑

[ocaml]
symbol = "🐫"

[package]
symbol = "🎁"

[perl]
symbol = "🐪"

[php]
symbol = "🐘"

[pulumi]
symbol = ""

[python]
symbol = "🐍"

[ruby]
symbol = "💎"

[rust]
symbol = "🦀"

[scala]
symbol = "🆂"

[swift]
symbol = "🐦"

[terraform]
symbol = "🛠"
'@ | Out-File -FilePath $starshipConfig -Encoding UTF8
            }
        }
    }

}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Success', 'Error', 'Warning', 'Verbose')]
        [string]$Level = 'Info'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "$timestamp [$Level] $Message"

    # Write to console with colors
    $color = $global:Colors[$Level]
    Write-Host $logMessage -ForegroundColor $color

    # Write to log file
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Start-InstallationLog {
    Write-Log "================================================" -Level Info
    Write-Log "Dev Tools Installation Started" -Level Info
    Write-Log "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info
    Write-Log "PowerShell Version: $($PSVersionTable.PSVersion)" -Level Info
    Write-Log "Windows Version: $([Environment]::OSVersion.Version)" -Level Info
    Write-Log "Running as Admin: $global:IsAdmin" -Level Info
    Write-Log "Parameters: $($PSBoundParameters | ConvertTo-Json -Compress)" -Level Info
    Write-Log "================================================" -Level Info
}

function Complete-InstallationLog {
    $duration = (Get-Date) - $global:ScriptStartTime
    Write-Log "================================================" -Level Info
    Write-Log "Installation Completed" -Level Info
    Write-Log "Total Duration: $($duration.ToString('hh\:mm\:ss'))" -Level Info
    Write-Log "Successful: $($global:InstallationResults.Count)" -Level Success
    Write-Log "Failed: $($global:FailedInstallations.Count)" -Level Error
    Write-Log "================================================" -Level Info

    if ($ExportResults) {
        $results = @{
            Successful = $global:InstallationResults
            Failed = $global:FailedInstallations
            Summary = @{
                TotalTime = $duration.ToString('hh\:mm\:ss')
                StartTime = $global:ScriptStartTime
                EndTime = Get-Date
                Parameters = $PSBoundParameters
            }
        }

        $results | ConvertTo-Json -Depth 5 | Out-File -FilePath $ExportResults -Encoding UTF8
        Write-Log "Results exported to: $ExportResults" -Level Success
    }
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Test-CommandExists {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-InternetConnection {
    try {
        $null = Invoke-WebRequest -Uri "https://github.com" -TimeoutSec 5
        return $true
    }
    catch {
        Write-Log "No internet connection detected" -Level Warning
        return $false
    }
}

function Add-ToPath {
    param(
        [string]$Path,
        [switch]$User,
        [switch]$System
    )

    if (-not (Test-Path $Path)) {
        Write-Log "Path does not exist: $Path" -Level Warning
        return $false
    }

    $scope = if ($System -and $global:IsAdmin) { 'Machine' } else { 'User' }
    $currentPath = [Environment]::GetEnvironmentVariable('Path', $scope)

    if ($currentPath -split ';' -notcontains $Path) {
        $newPath = "$currentPath;$Path"
        [Environment]::SetEnvironmentVariable('Path', $newPath, $scope)

        # Update current session
        $env:Path = "$env:Path;$Path"

        Write-Log "Added to PATH ($scope): $Path" -Level Success
        return $true
    }

    Write-Log "Already in PATH: $Path" -Level Verbose
    return $true
}

function Get-LatestGitHubRelease {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repo,

        [Parameter()]
        [string]$Filter = "*windows*.exe"
    )

    try {
        $apiUrl = "https://api.github.com/repos/$Repo/releases/latest"
        Write-Log "Fetching GitHub release from: $apiUrl" -Level Verbose

        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{
            'Accept' = 'application/vnd.github.v3+json'
        } -ErrorAction Stop

        $asset = $release.assets | Where-Object { $_.name -like $Filter } | Select-Object -First 1

        if ($asset) {
            Write-Log "Found asset: $($asset.name)" -Level Verbose
            return @{
                Version = $release.tag_name
                Url = $asset.browser_download_url
                Name = $asset.name
            }
        }
        else {
            # Fallback to source code zip
            $asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
            if ($asset) {
                return @{
                    Version = $release.tag_name
                    Url = $asset.browser_download_url
                    Name = $asset.name
                }
            }
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Failed to get GitHub release for ${Repo}: $errorMessage" -Level Warning
    }

    return $null
}

function Invoke-Retry {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter()]
        [int]$MaxRetries = 3,

        [Parameter()]
        [int]$RetryDelay = 2
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -le $MaxRetries) {
        try {
            if ($attempt -gt 0) {
                Write-Log "Retry attempt $attempt of $MaxRetries..." -Level Warning
                Start-Sleep -Seconds $RetryDelay
            }

            return & $ScriptBlock
        }
        catch {
            $lastError = $_
            $attempt++

            if ($attempt -le $MaxRetries) {
                $errorMessage = $_.Exception.Message
                Write-Log "Attempt $attempt failed: $errorMessage" -Level Warning
            }
        }
    }

    throw "Failed after $MaxRetries attempts. Last error: $lastError"
}

# ============================================================================
# INSTALLATION METHODS
# ============================================================================

function Install-WithWinGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter()]
        [string]$CustomArgs = ''
    )

    if (-not (Test-CommandExists 'winget')) {
        Write-Log "WinGet is not available" -Level Warning
        return $false
    }

    if ($SkipWinget -or $FallbackOnly) {
        Write-Log "Skipping WinGet as requested" -Level Info
        return $false
    }

    try {
        Write-Log "Installing with WinGet: $PackageId" -Level Info

        $command = "winget install --id `"$PackageId`" --accept-package-agreements --accept-source-agreements --silent"

        if ($Force) {
            $command += " --force"
        }

        if ($CustomArgs) {
            $command += " $CustomArgs"
        }

        if ($WhatIfPreference) {
            Write-Log "[WhatIf] Would run: $command" -Level Verbose
            return $true
        }

        Write-Log "Running: $command" -Level Verbose
        $result = Invoke-Expression $command

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully installed with WinGet: $PackageId" -Level Success
            return $true
        }
        else {
            Write-Log "WinGet installation failed for $PackageId (Exit code: $LASTEXITCODE)" -Level Error
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "WinGet installation error for ${PackageId}: $errorMessage" -Level Error
        return $false
    }
}

function Install-PowerShellModule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    try {
        Write-Log "Installing PowerShell module: $ModuleName" -Level Info

        if ($WhatIfPreference) {
            Write-Log "[WhatIf] Would install PowerShell module: $ModuleName" -Level Verbose
            return $true
        }

        # Check if module is already installed
        $existingModule = Get-Module -ListAvailable -Name $ModuleName
        if ($existingModule -and -not $Force) {
            Write-Log "PowerShell module already installed: $ModuleName" -Level Warning
            return $true
        }

        # Install or update the module
        if ($Force) {
            Install-Module -Name $ModuleName -Force -Scope CurrentUser -AllowClobber
        } else {
            Install-Module -Name $ModuleName -Scope CurrentUser -AllowClobber
        }

        Write-Log "Successfully installed PowerShell module: $ModuleName" -Level Success
        return $true
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Failed to install PowerShell module ${ModuleName}: $errorMessage" -Level Error
        return $false
    }
}

function Install-NodePackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    # Check if Node.js is installed
    if (-not (Test-CommandExists 'npm')) {
        Write-Log "Node.js/npm is not installed. Please install Node.js first." -Level Error
        return $false
    }

    try {
        Write-Log "Installing Node.js package: $PackageName" -Level Info

        if ($WhatIfPreference) {
            Write-Log "[WhatIf] Would install Node.js package: $PackageName" -Level Verbose
            return $true
        }

        # Check if package is already installed globally
        $installed = npm list -g $PackageName --depth=0 2>$null
        if ($installed -and -not $Force) {
            Write-Log "Node.js package already installed: $PackageName" -Level Warning
            return $true
        }

        # Install the package
        if ($Force) {
            npm install -g $PackageName --force
        } else {
            npm install -g $PackageName
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully installed Node.js package: $PackageName" -Level Success
            return $true
        } else {
            Write-Log "Failed to install Node.js package: $PackageName" -Level Error
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error installing Node.js package ${PackageName}: $errorMessage" -Level Error
        return $false
    }
}

function Install-PythonPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName
    )

    # Check if Python is installed
    if (-not (Test-CommandExists 'pip')) {
        Write-Log "Python/pip is not installed. Please install Python first." -Level Error
        return $false
    }

    try {
        Write-Log "Installing Python package: $PackageName" -Level Info

        if ($WhatIfPreference) {
            Write-Log "[WhatIf] Would install Python package: $PackageName" -Level Verbose
            return $true
        }

        # Install the package
        pip install $PackageName

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully installed Python package: $PackageName" -Level Success
            return $true
        } else {
            Write-Log "Failed to install Python package: $PackageName" -Level Error
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Error installing Python package ${PackageName}: $errorMessage" -Level Error
        return $false
    }
}

function Install-FromGitHub {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ToolConfig
    )

    if (-not $ToolConfig.GitHubRepo) {
        Write-Log "No GitHub repository configured for $($ToolConfig.Name)" -Level Warning
        return $false
    }

    try {
        Write-Log "Checking GitHub releases for $($ToolConfig.Name)..." -Level Info

        $release = Get-LatestGitHubRelease -Repo $ToolConfig.GitHubRepo -Filter "*windows*"

        if (-not $release) {
            Write-Log "No suitable release found for $($ToolConfig.Name)" -Level Warning
            return $false
        }

        Write-Log "Found release: $($release.Version)" -Level Info

        $downloadFile = Join-Path $DownloadPath $release.Name

        if (-not (Test-Path $downloadFile) -or $Force) {
            Write-Log "Downloading from GitHub: $($release.Url)" -Level Info

            if ($WhatIfPreference) {
                Write-Log "[WhatIf] Would download: $($release.Url)" -Level Verbose
                return $true
            }

            if (-not (Test-Path $DownloadPath)) {
                New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
            }

            Invoke-WebRequest -Uri $release.Url -OutFile $downloadFile -ErrorAction Stop
            Write-Log "Download completed: $downloadFile" -Level Success
        }
        else {
            Write-Log "Using cached file: $downloadFile" -Level Verbose
        }

        # Install based on file type
        switch ($ToolConfig.InstallerType) {
            'exe' {
                $silentArgs = if ($ToolConfig.SilentArgs) { $ToolConfig.SilentArgs } else { '/S' }
                Start-Process -FilePath $downloadFile -ArgumentList $silentArgs -Wait -NoNewWindow
            }
            'msi' {
                $silentArgs = if ($ToolConfig.SilentArgs) { $ToolConfig.SilentArgs } else { '/quiet /norestart' }
                Start-Process msiexec.exe -ArgumentList "/i `"$downloadFile`" $silentArgs" -Wait -NoNewWindow
            }
            'zip' {
                $extractPath = Join-Path $DownloadPath $ToolConfig.Name
                Expand-Archive -Path $downloadFile -DestinationPath $extractPath -Force

                # Add to PATH if binary exists
                if ($ToolConfig.BinaryName) {
                    $binary = Get-ChildItem -Path $extractPath -Recurse -Filter $ToolConfig.BinaryName | Select-Object -First 1
                    if ($binary) {
                        Add-ToPath -Path $binary.DirectoryName -User
                    }
                }
            }
            'ps1' {
                # For mise installation script
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$downloadFile`"" -Wait -NoNewWindow
            }
        }

        if (-not $ForceDownload) {
            Remove-Item $downloadFile -Force -ErrorAction SilentlyContinue
        }

        return $true
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "GitHub installation failed for $($ToolConfig.Name): $errorMessage" -Level Error
        return $false
    }
}

function Install-WithChocolatey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter()]
        [hashtable]$ToolConfig
    )

    if (-not (Test-CommandExists 'choco')) {
        Write-Log "Chocolatey is not available" -Level Warning
        return $false
    }

    try {
        Write-Log "Installing with Chocolatey: $PackageId" -Level Info

        if ($WhatIfPreference) {
            Write-Log "[WhatIf] Would run: choco install $PackageId -y" -Level Verbose
            return $true
        }

        $command = "choco install $PackageId -y --no-progress"
        if ($Force) {
            $command += " --force"
        }

        $result = Invoke-Expression $command

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully installed with Chocolatey: $PackageId" -Level Success
            return $true
        }
        else {
            Write-Log "Chocolatey installation failed for $PackageId (Exit code: $LASTEXITCODE)" -Level Error
            return $false
        }
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Chocolatey installation error for ${PackageId}: $errorMessage" -Level Error
        return $false
    }
}

function Install-DirectDownload {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$ToolConfig
    )

    if (-not $ToolConfig.DirectUrl) {
        Write-Log "No direct download URL configured for $($ToolConfig.Name)" -Level Warning
        return $false
    }

    try {
        Write-Log "Downloading directly: $($ToolConfig.Name)" -Level Info

        # Generate download filename
        $fileName = if ($ToolConfig.InstallerType) {
            "$($ToolConfig.Name).$($ToolConfig.InstallerType)"
        } else {
            "$($ToolConfig.Name).exe"
        }
        $downloadFile = Join-Path $DownloadPath $fileName

        if (-not (Test-Path $downloadFile) -or $Force) {
            if ($WhatIfPreference) {
                Write-Log "[WhatIf] Would download from: $($ToolConfig.DirectUrl)" -Level Verbose
                return $true
            }

            if (-not (Test-Path $DownloadPath)) {
                New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
            }

            Invoke-WebRequest -Uri $ToolConfig.DirectUrl -OutFile $downloadFile -ErrorAction Stop
            Write-Log "Download completed: $downloadFile" -Level Success
        }
        else {
            Write-Log "Using cached file: $downloadFile" -Level Verbose
        }

        # Install based on file type
        switch ($ToolConfig.InstallerType) {
            'exe' {
                $silentArgs = if ($ToolConfig.SilentArgs) { $ToolConfig.SilentArgs } else { '/S' }
                Start-Process -FilePath $downloadFile -ArgumentList $silentArgs -Wait -NoNewWindow
            }
            'msi' {
                $silentArgs = if ($ToolConfig.SilentArgs) { $ToolConfig.SilentArgs } else { '/quiet /norestart' }
                Start-Process msiexec.exe -ArgumentList "/i `"$downloadFile`" $silentArgs" -Wait -NoNewWindow
            }
            'zip' {
                $extractPath = Join-Path $DownloadPath $ToolConfig.Name
                Expand-Archive -Path $downloadFile -DestinationPath $extractPath -Force

                if ($ToolConfig.BinaryName) {
                    $binary = Get-ChildItem -Path $extractPath -Recurse -Filter $ToolConfig.BinaryName | Select-Object -First 1
                    if ($binary) {
                        Add-ToPath -Path $binary.DirectoryName -User
                    }
                }
            }
        }

        if (-not $ForceDownload) {
            Remove-Item $downloadFile -Force -ErrorAction SilentlyContinue
        }

        return $true
    }
    catch {
        $errorMessage = $_.Exception.Message
        Write-Log "Direct download installation failed for $($ToolConfig.Name): $errorMessage" -Level Error
        return $false
    }
}

# ============================================================================
# MAIN INSTALLATION FUNCTION
# ============================================================================

function Install-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ToolName,

        [Parameter(Mandatory = $true)]
        [hashtable]$ToolConfig
    )

    Write-Log "`n--- Installing $($ToolConfig.Name) ($ToolName) ---" -Level Info

    # Skip if already installed (unless forced)
    if ($ToolConfig.InstallCheck -and (& $ToolConfig.InstallCheck) -and -not $Force) {
        Write-Log "$($ToolConfig.Name) is already installed" -Level Warning
        $global:InstallationResults += [PSCustomObject]@{
            Tool = $ToolName
            Name = $ToolConfig.Name
            Status = 'Skipped'
            Method = 'AlreadyInstalled'
            Timestamp = Get-Date
        }
        return $true
    }

    # Determine which methods to try based on available installation methods
    $methods = @()

    # Check for special installation types first
    if ($ToolConfig.ContainsKey('PowerShellModule') -and $ToolConfig.PowerShellModule) {
        $methods += 'PowerShellModule'
    }
    elseif ($ToolConfig.ContainsKey('NodePackage') -and $ToolConfig.NodePackage) {
        $methods += 'NodePackage'
    }
    elseif ($ToolConfig.ContainsKey('PythonPackage') -and $ToolConfig.PythonPackage) {
        $methods += 'PythonPackage'
    }
    else {
        # Regular installation methods
        if ($Method -eq 'All') {
            if (-not $FallbackOnly) {
                if ($ToolConfig.ContainsKey('WinGetId') -and $ToolConfig.WinGetId) { $methods += 'WinGet' }
            }
            if ($ToolConfig.ContainsKey('GitHubRepo') -and $ToolConfig.GitHubRepo) { $methods += 'GitHub' }
            if ($ToolConfig.ContainsKey('DirectUrl') -and $ToolConfig.DirectUrl) { $methods += 'Direct' }
            if ($ToolConfig.ContainsKey('ChocolateyId') -and $ToolConfig.ChocolateyId) { $methods += 'Chocolatey' }
        }
        else {
            switch ($Method) {
                'WinGet' {
                    if ($ToolConfig.ContainsKey('WinGetId') -and $ToolConfig.WinGetId) {
                        $methods = @('WinGet')
                    }
                }
                'GitHub' {
                    if ($ToolConfig.ContainsKey('GitHubRepo') -and $ToolConfig.GitHubRepo) {
                        $methods = @('GitHub')
                    }
                }
                'Direct' {
                    if ($ToolConfig.ContainsKey('DirectUrl') -and $ToolConfig.DirectUrl) {
                        $methods = @('Direct')
                    }
                }
                'Chocolatey' {
                    if ($ToolConfig.ContainsKey('ChocolateyId') -and $ToolConfig.ChocolateyId) {
                        $methods = @('Chocolatey')
                    }
                }
            }
        }
    }

    if ($SkipWinget) {
        $methods = $methods | Where-Object { $_ -ne 'WinGet' }
    }

    # If no methods found, log error and return
    if ($methods.Count -eq 0) {
        Write-Log "No installation methods available for $($ToolConfig.Name)" -Level Error
        $global:FailedInstallations += [PSCustomObject]@{
            Tool = $ToolName
            Name = $ToolConfig.Name
            Status = 'NoMethodsAvailable'
            MethodsTried = @()
            Timestamp = Get-Date
        }
        return $false
    }

    # Try each method until one succeeds
    $success = $false
    $methodUsed = ''

    foreach ($method in $methods) {
        Write-Log "Trying installation method: $method" -Level Verbose

        switch ($method) {
            'WinGet' {
                $success = Install-WithWinGet -PackageId $ToolConfig.WinGetId
                if ($success) { $methodUsed = 'WinGet' }
            }
            'PowerShellModule' {
                $success = Install-PowerShellModule -ModuleName $ToolConfig.PowerShellModule
                if ($success) { $methodUsed = 'PowerShellModule' }
            }
            'NodePackage' {
                $success = Install-NodePackage -PackageName $ToolConfig.NodePackage
                if ($success) { $methodUsed = 'NodePackage' }
            }
            'PythonPackage' {
                $success = Install-PythonPackage -PackageName $ToolConfig.PythonPackage
                if ($success) { $methodUsed = 'PythonPackage' }
            }
            'GitHub' {
                $success = Install-FromGitHub -ToolConfig $ToolConfig
                if ($success) { $methodUsed = 'GitHub' }
            }
            'Direct' {
                $success = Install-DirectDownload -ToolConfig $ToolConfig
                if ($success) { $methodUsed = 'Direct' }
            }
            'Chocolatey' {
                $success = Install-WithChocolatey -PackageId $ToolConfig.ChocolateyId -ToolConfig $ToolConfig
                if ($success) { $methodUsed = 'Chocolatey' }
            }
        }

        if ($success) {
            # Run post-installation steps if defined
            if ($ToolConfig.ContainsKey('PostInstall') -and $ToolConfig.PostInstall) {
                try {
                    Write-Log "Running post-installation steps..." -Level Verbose
                    & $ToolConfig.PostInstall
                }
                catch {
                    $errorMessage = $_.Exception.Message
                    Write-Log "Post-installation steps failed: $errorMessage" -Level Warning
                }
            }

            # Verify installation
            if ($ToolConfig.InstallCheck) {
                if (& $ToolConfig.InstallCheck) {
                    Write-Log "$($ToolConfig.Name) installation verified" -Level Success

                    $global:InstallationResults += [PSCustomObject]@{
                        Tool = $ToolName
                        Name = $ToolConfig.Name
                        Status = 'Success'
                        Method = $methodUsed
                        Timestamp = Get-Date
                    }
                    return $true
                }
                else {
                    Write-Log "$($ToolConfig.Name) installation may have failed (verification unsuccessful)" -Level Warning
                }
            }
            else {
                # If no install check, assume success
                $global:InstallationResults += [PSCustomObject]@{
                    Tool = $ToolName
                    Name = $ToolConfig.Name
                    Status = 'Success'
                    Method = $methodUsed
                    Timestamp = Get-Date
                }
                return $true
            }
        }
    }

    # All methods failed
    Write-Log "All installation methods failed for $($ToolConfig.Name)" -Level Error

    $global:FailedInstallations += [PSCustomObject]@{
        Tool = $ToolName
        Name = $ToolConfig.Name
        Status = 'Failed'
        MethodsTried = $methods
        Timestamp = Get-Date
    }

    return $false
}

# ============================================================================
# PREREQUISITE CHECKS AND SETUP
# ============================================================================

function Initialize-Environment {
    Write-Log "Initializing environment..." -Level Info

    # Create download directory
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
        Write-Log "Created download directory: $DownloadPath" -Level Success
    }

    # Check internet connection
    if (-not (Test-InternetConnection)) {
        Write-Log "Internet connection required for installation" -Level Error
        exit 1
    }

    # Check for admin rights if needed
    if (-not $global:IsAdmin) {
        Write-Log "Running without administrator privileges" -Level Warning
        Write-Log "Some installations may require elevation" -Level Warning
    }

    # Check for package managers
    if (Test-CommandExists 'winget') {
        Write-Log "WinGet is available" -Level Success
    } else {
        Write-Log "WinGet is not available (will use fallback methods)" -Level Warning
    }

    if (Test-CommandExists 'choco') {
        Write-Log "Chocolatey is available" -Level Success
    } else {
        Write-Log "Chocolatey is not available" -Level Verbose
    }

    # Check for Node.js/npm
    if (Test-CommandExists 'npm') {
        Write-Log "Node.js/npm is available" -Level Success
    }

    # Check for Python/pip
    if (Test-CommandExists 'pip') {
        Write-Log "Python/pip is available" -Level Success
    }
}

function Install-PackageManagers {
    Write-Log "`n--- Installing Package Managers ---" -Level Info

    # Install WinGet if not present
    if (-not (Test-CommandExists 'winget') -and -not $SkipWinget -and -not $FallbackOnly) {
        Write-Log "WinGet is not installed. Attempting to install..." -Level Info

        try {
            if ($global:IsAdmin) {
                # Download and install App Installer from Microsoft Store
                $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
                $wingetFile = Join-Path $DownloadPath "Microsoft.DesktopAppInstaller.msixbundle"

                if (-not $WhatIfPreference) {
                    Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetFile
                    Add-AppxPackage -Path $wingetFile
                    Write-Log "WinGet installed successfully" -Level Success
                } else {
                    Write-Log "[WhatIf] Would install WinGet" -Level Verbose
                }
            } else {
                Write-Log "Administrator privileges required to install WinGet" -Level Warning
            }
        } catch {
            $errorMessage = $_.Exception.Message
            Write-Log "Failed to install WinGet: $errorMessage" -Level Error
        }
    }

    # Install Chocolatey if not present
    if (-not (Test-CommandExists 'choco') -and $global:IsAdmin -and -not $WhatIfPreference) {
        Write-Log "Chocolatey is not installed. Would you like to install it? (Y/N)" -Level Info
        $response = Read-Host

        if ($response -match '^[Yy]') {
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
                Write-Log "Chocolatey installed successfully" -Level Success
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Log "Failed to install Chocolatey: $errorMessage" -Level Error
            }
        }
    }
}

# ============================================================================
# MAIN SCRIPT EXECUTION
# ============================================================================

function Main {
    # Start logging
    Start-InstallationLog

    # Initialize environment
    Initialize-Environment

    # Install package managers if needed
    if (-not $WhatIfPreference) {
        Install-PackageManagers
    }

    # Filter tools by category if specified
    $allTools = $global:ToolDefinitions.Keys
    $filteredTools = @()

    if ($Category -contains 'All') {
        $filteredTools = $allTools
    } else {
        foreach ($tool in $allTools) {
            $toolCategory = $global:ToolDefinitions[$tool].Category
            if ($Category -contains $toolCategory) {
                $filteredTools += $tool
            }
        }
    }

    # Further filter by explicit tool list or skip list
    $toolsToInstall = if ($Tools) {
        $Tools | ForEach-Object { $_.Trim() } | Where-Object { $_ -in $filteredTools }
    } else {
        $filteredTools | Where-Object { $_ -notin $SkipTools }
    }

    Write-Log "`nTools to install: $($toolsToInstall -join ', ')" -Level Info
    Write-Log "Categories selected: $($Category -join ', ')" -Level Info

    # Track progress
    $totalTools = $toolsToInstall.Count
    $currentTool = 0

    # Install tools
    foreach ($tool in $toolsToInstall) {
        $currentTool++
        Write-Progress -Activity "Installing Development Tools" -Status "Installing $tool ($currentTool of $totalTools)" -PercentComplete (($currentTool / $totalTools) * 100)

        if ($global:ToolDefinitions.ContainsKey($tool)) {
            $result = Install-Tool -ToolName $tool -ToolConfig $global:ToolDefinitions[$tool]

            if (-not $result) {
                Write-Log "Failed to install: $tool" -Level Error
            }
        } else {
            Write-Log "Unknown tool: $tool" -Level Error
            $global:FailedInstallations += [PSCustomObject]@{
                Tool = $tool
                Name = $tool
                Status = 'UnknownTool'
                Timestamp = Get-Date
            }
        }

        # Brief pause between installations
        Start-Sleep -Milliseconds 500
    }

    Write-Progress -Activity "Installing Development Tools" -Completed

    # Post-installation tasks
    Write-Log "`n--- Post-Installation Tasks ---" -Level Info

    # Update PowerShell profile with useful aliases and configurations
    $profileContent = @'
# ============================================================================
# Dev Tools Configuration
# ============================================================================

# Aliases for modern replacements
Set-Alias ll eza
Set-Alias la eza -a
Set-Alias lt eza --tree
Set-Alias grep rg
Set-Alias find fd
Set-Alias cat bat
Set-Alias tree tre
Set-Alias ag silver_searcher

# Git aliases
function gst { git status }
function gco { git checkout }
function gcm { git commit -m }
function ga { git add }
function gl { git log --oneline --graph }
function gd { git diff }
function gps { git push }
function gpl { git pull }
function gbr { git branch }
function gsw { git switch }

# Navigation
function cdz { Set-Location $(zoxide query $args) }
function ff { fd --type f | fzf | Set-Clipboard }

# Quick edit
function vim { nvim $args }
function vi { nvim $args }

# System info
function sysinfo { fastfetch }

# Network utilities
function myip { curl -s https://ipinfo.io/ip }
function speedtest { curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python - }

# Docker aliases
function dps { docker ps }
function dcu { docker-compose up }
function dcd { docker-compose down }
function dcr { docker-compose restart }

# Development
function godev { cd ~/dev }
function pyclean { Remove-Item -Force -Recurse __pycache__, *.pyc }
function nodeclean { Remove-Item -Force -Recurse node_modules }

# PowerShell enhancements
function which ($command) { Get-Command $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Path }
function mkcd ($path) { New-Item -ItemType Directory -Path $path; Set-Location $path }
function touch ($file) { New-Item -ItemType File -Path $file }

# Color output for common commands
function Get-ChildItemColor {
    param([string]$Path = ".")
    Get-ChildItem $Path | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Host $_.Name -ForegroundColor Blue
        } elseif ($_.Extension -match '\.(ps1|bat|cmd|sh)$') {
            Write-Host $_.Name -ForegroundColor Green
        } elseif ($_.Extension -match '\.(txt|md|log)$') {
            Write-Host $_.Name -ForegroundColor Gray
        } elseif ($_.Extension -match '\.(exe|msi)$') {
            Write-Host $_.Name -ForegroundColor Yellow
        } else {
            Write-Host $_.Name
        }
    }
}
Set-Alias lsc Get-ChildItemColor

# Initialize zoxide if available
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    Invoke-Expression (& { (zoxide init --hook $hook powershell | Out-String) })
}

# Initialize mise if available
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate powershell | Out-String | Invoke-Expression
}

# Initialize starship if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# Import useful modules
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# Enhanced prompt
function prompt {
    $path = (Get-Location).Path.Replace($HOME, '~')
    $user = [System.Environment]::UserName
    $hostname = [System.Environment]::MachineName

    # Git status if in git repo
    $gitStatus = ""
    if (Test-Path .git -PathType Container) {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
        if ($branch) {
            $status = git status --porcelain 2>$null
            $color = if ($status) { "Red" } else { "Green" }
            $gitStatus = " [$branch]"
        }
    }

    # Set prompt
    Write-Host "$user@$hostname " -NoNewline -ForegroundColor Cyan
    Write-Host $path -NoNewline -ForegroundColor Yellow
    if ($gitStatus) {
        Write-Host $gitStatus -NoNewline -ForegroundColor $color
    }
    Write-Host "> " -NoNewline -ForegroundColor White
    return " "
}
'@

    $profilePath = if ($PROFILE) { $PROFILE } else { "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }

    if (-not $WhatIfPreference) {
        $profileDir = Split-Path $profilePath -Parent
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        if (-not (Test-Path $profilePath) -or $Force) {
            $profileContent | Out-File -FilePath $profilePath -Encoding UTF8
            Write-Log "Updated PowerShell profile: $profilePath" -Level Success
        } else {
            # Check if our content is already in the profile
            $currentContent = Get-Content $profilePath -Raw
            if (-not $currentContent.Contains("# Dev Tools Configuration")) {
                $profileContent | Out-File -FilePath $profilePath -Encoding UTF8 -Append
                Write-Log "Appended to PowerShell profile: $profilePath" -Level Success
            } else {
                Write-Log "PowerShell profile already contains dev tools configuration" -Level Warning
            }
        }
    } else {
        Write-Log "[WhatIf] Would update PowerShell profile" -Level Verbose
    }

    # Final summary
    Complete-InstallationLog

    # Show summary
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "INSTALLATION SUMMARY" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "Successful: $($global:InstallationResults.Count)" -ForegroundColor Green
    Write-Host "Failed: $($global:FailedInstallations.Count)" -ForegroundColor Red

    if ($global:FailedInstallations.Count -gt 0) {
        Write-Host "`nFailed installations:" -ForegroundColor Yellow
        $global:FailedInstallations | ForEach-Object {
            Write-Host "  - $($_.Name) ($($_.Tool))" -ForegroundColor Red
        }
    }

    Write-Host "`nLog file: $LogPath" -ForegroundColor Gray
    if ($ExportResults) {
        Write-Host "Results exported to: $ExportResults" -ForegroundColor Gray
    }

    # Show next steps
    Write-Host "`n" + "="*60 -ForegroundColor Cyan
    Write-Host "NEXT STEPS" -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    Write-Host "1. Restart your terminal for all changes to take effect" -ForegroundColor Yellow
    Write-Host "2. Run 'refreshenv' or restart PowerShell to update environment variables" -ForegroundColor Yellow
    Write-Host "3. Configure individual tools as needed:" -ForegroundColor Yellow
    Write-Host "   - Run 'gh auth login' for GitHub CLI" -ForegroundColor White
    Write-Host "   - Run 'git config --global user.name/email' for Git" -ForegroundColor White
    Write-Host "   - Customize Starship prompt: ~/.config/starship.toml" -ForegroundColor White
    Write-Host "4. Explore new tools with:" -ForegroundColor Yellow
    Write-Host "   - 'lazygit' for Git UI" -ForegroundColor White
    Write-Host "   - 'yazi' for file management" -ForegroundColor White
    Write-Host "   - 'btop' for system monitoring" -ForegroundColor White
    Write-Host "   - 'tldr <command>' for help" -ForegroundColor White
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

try {
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-Warning "This script is designed for PowerShell 7+. Some features may not work in PowerShell $($PSVersionTable.PSVersion.Major)"
        Write-Warning "Consider installing PowerShell 7 from: https://github.com/PowerShell/PowerShell"
    }

    # Execute main function
    Main
}
catch {
    $errorMessage = $_.Exception.Message
    $stackTrace = $_.ScriptStackTrace
    Write-Log "Script execution failed: $errorMessage" -Level Error
    Write-Log "Stack trace: $stackTrace" -Level Error
    exit 1
}
