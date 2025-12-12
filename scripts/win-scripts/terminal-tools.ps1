# terminal-tools.ps1
# Complete terminal tools installer with WinGet fallback strategies
# PowerShell 5.1 compatible version
# Run: .\terminal-tools.ps1 [-SkipWinget] [-FallbackOnly] [-ForceDownload] [-WhatIf]

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$DownloadPath = "$env:USERPROFILE\bin",

    [Parameter()]
    [string]$LogPath = "$env:TEMP\terminal-tools-logs",

    [Parameter()]
    [switch]$SkipWinget,

    [Parameter()]
    [switch]$FallbackOnly,

    [Parameter()]
    [switch]$ForceDownload,

    [Parameter()]
    [switch]$WhatIf,

    [Parameter()]
    [ValidateSet('All', 'Winget', 'GitHub', 'Direct', 'Chocolatey')]
    [string]$Method = 'All',

    [Parameter()]
    [switch]$SkipChecksum,

    [Parameter()]
    [int]$MaxConcurrentDownloads = 3
)

#region Configuration
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$global:InstallationResults = @()
$global:StartTime = Get-Date

# Tool configuration with multiple fallback strategies
$ToolsConfig = @{
    Git = @{
        WingetId = 'Git.Git'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'git-for-windows'
                Repo = 'git'
                AssetPattern = 'Git-.*-64-bit\.exe$'
                Extract = $false
            }
            Chocolatey = @{
                Package = 'git'
                Args = @('--params', "'/NoGitLfs /SChannel /WindowsTerminal'")
            }
        }
        Binaries = @('git.exe', 'git-bash.exe')
        Path = @('Git\cmd', 'Git\bin')
    }

    LazyGit = @{
        WingetId = 'JesseDuffield.lazygit'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'jesseduffield'
                Repo = 'lazygit'
                AssetPattern = 'lazygit_.*_Windows_x86_64\.zip$'
                Extract = $true
                ExtractDir = 'lazygit'
            }
        }
        Binaries = @('lazygit.exe')
        Path = '.'
    }

    Ripgrep = @{
        WingetId = 'BurntSushi.ripgrep.MSVC'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'BurntSushi'
                Repo = 'ripgrep'
                AssetPattern = 'ripgrep-.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('rg.exe')
        Path = '.'
    }

    Fd = @{
        WingetId = 'sharkdp.fd'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'sharkdp'
                Repo = 'fd'
                AssetPattern = 'fd-v.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('fd.exe')
        Path = '.'
    }

    Fzf = @{
        WingetId = 'junegunn.fzf'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'junegunn'
                Repo = 'fzf'
                AssetPattern = 'fzf-.*-windows_amd64\.zip$'
                Extract = $true
            }
            Chocolatey = @{
                Package = 'fzf'
            }
        }
        Binaries = @('fzf.exe')
        Path = '.'
    }

    Bat = @{
        WingetId = 'sharkdp.bat'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'sharkdp'
                Repo = 'bat'
                AssetPattern = 'bat-v.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('bat.exe')
        Path = '.'
    }

    Delta = @{
        WingetId = 'dandavison.delta'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'dandavison'
                Repo = 'delta'
                AssetPattern = 'delta-.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('delta.exe')
        Path = '.'
    }

    Eza = @{
        WingetId = 'eza.eza'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'eza-community'
                Repo = 'eza'
                AssetPattern = 'eza_.*_windows-x86_64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('eza.exe')
        Path = '.'
    }

    Gsudo = @{
        WingetId = 'gerardog.gsudo'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'gerardog'
                Repo = 'gsudo'
                AssetPattern = 'gsudo\.v.*-x64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('gsudo.exe')
        Path = '.'
    }

    Starship = @{
        WingetId = 'starship.starship'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'starship'
                Repo = 'starship'
                AssetPattern = 'starship-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
            Chocolatey = @{
                Package = 'starship'
            }
        }
        Binaries = @('starship.exe')
        Path = '.'
    }

    Neovim = @{
        WingetId = 'Neovim.Neovim'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'neovim'
                Repo = 'neovim'
                AssetPattern = 'nvim-win64\.zip$'
                Extract = $true
                ExtractDir = 'nvim'
            }
        }
        Binaries = @('nvim.exe')
        Path = 'nvim\bin'
    }

    VSCode = @{
        WingetId = 'Microsoft.VisualStudioCode'
        Methods = @{
            Winget = $true
            Direct = @{
                Url = 'https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user'
                Installer = 'VSCodeSetup.exe'
                Args = '/VERYSILENT /MERGETASKS=!runcode'
            }
        }
    }

    Tldr = @{
        WingetId = 'dbrgn.tealdeer'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'dbrgn'
                Repo = 'tealdeer'
                AssetPattern = 'tealdeer-windows-x86_64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('tldr.exe')
        Path = '.'
    }

    Zoxide = @{
        WingetId = 'ajeetdsouza.zoxide'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'ajeetdsouza'
                Repo = 'zoxide'
                AssetPattern = 'zoxide-.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('zoxide.exe')
        Path = '.'
    }

    Fastfetch = @{
        WingetId = 'fastfetch.fastfetch'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'fastfetch-cli'
                Repo = 'fastfetch'
                AssetPattern = 'fastfetch-windows-x86_64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('fastfetch.exe')
        Path = '.'
    }

    Yazi = @{
        WingetId = 'yazi.yazi'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'sxyazi'
                Repo = 'yazi'
                AssetPattern = 'yazi-x86_64-windows\.zip$'
                Extract = $true
            }
        }
        Binaries = @('yazi.exe')
        Path = '.'
    }

    GitHubCLI = @{
        WingetId = 'GitHub.cli'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'cli'
                Repo = 'cli'
                AssetPattern = 'gh_.*_windows_amd64\.msi$'
                Extract = $false
            }
        }
    }

    Vale = @{
        WingetId = 'errata-ai.vale'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'errata-ai'
                Repo = 'vale'
                AssetPattern = 'vale_.*_Windows_64-bit\.zip$'
                Extract = $true
            }
        }
        Binaries = @('vale.exe')
        Path = '.'
    }

    SilverSearcher = @{
        WingetId = 'JFLarvoire.Ag'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'k-takata'
                Repo = 'the_silver_searcher-win32'
                AssetPattern = 'ag-x64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('ag.exe')
        Path = '.'
    }

    Tre = @{
        WingetId = 'onetrueerror.tre'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'onetrueerror'
                Repo = 'tre-command'
                AssetPattern = 'tre-.*-x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('tre.exe')
        Path = '.'
    }

    Glow = @{
        WingetId = 'charmbracelet.glow'
        Methods = @{
            Winget = $true
            GitHub = @{
                Owner = 'charmbracelet'
                Repo = 'glow'
                AssetPattern = 'glow_.*_windows_x86_64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('glow.exe')
        Path = '.'
    }

    MiKTeX = @{
        WingetId = 'MiKTeX.MiKTeX'
        Methods = @{
            Winget = $true
            Direct = @{
                Url = 'https://miktex.org/download/ctan/systems/win32/miktex/setup/windows-x64/basic-miktex-23.12-x64.exe'
                Installer = 'miktex-setup.exe'
                Args = '--unattended'
            }
        }
    }

    Lua = @{
        WingetId = 'DEVCOM.Lua'
        Methods = @{
            Winget = $true
            Direct = @{
                Url = 'https://sourceforge.net/projects/luabinaries/files/5.4.6/Executables/lua-5.4.6_Win64_bin.zip'
                Installer = 'lua.zip'
                Extract = $true
            }
        }
        Binaries = @('lua.exe', 'luac.exe')
        Path = '.'
    }

    Globalping = @{
        WingetId = 'globalping.globalping'
        Methods = @{
            Winget = $true
            Chocolatey = @{
                Package = 'globalping-cli'
            }
        }
        Binaries = @('globalping.exe')
        Path = '.'
    }

    # Bonus tools without WinGet IDs
    Bottom = @{
        Methods = @{
            GitHub = @{
                Owner = 'ClementTsang'
                Repo = 'bottom'
                AssetPattern = 'btm_x86_64-pc-windows-msvc\.zip$'
                Extract = $true
            }
        }
        Binaries = @('btm.exe')
        Path = '.'
    }

    Dog = @{
        Methods = @{
            GitHub = @{
                Owner = 'ogham'
                Repo = 'dog'
                AssetPattern = 'dog-windows-x86_64\.zip$'
                Extract = $true
            }
        }
        Binaries = @('dog.exe')
        Path = '.'
    }
}
#endregion

#region Utility Functions
function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Verbose')]
        [string]$Level = 'Info',

        [switch]$NoNewLine
    )

    $timestamp = Get-Date -Format 'HH:mm:ss'
    $color = @{
        'Info' = 'White'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Verbose' = 'Gray'
    }[$Level]

    $prefix = @{
        'Info' = '[i]'
        'Success' = '[✓]'
        'Warning' = '[!]'
        'Error' = '[✗]'
        'Verbose' = '[?]'
    }[$Level]

    if ($NoNewLine) {
        Write-Host "$timestamp $prefix $Message" -ForegroundColor $color -NoNewline
    } else {
        Write-Host "$timestamp $prefix $Message" -ForegroundColor $color
    }

    # Also write to log file
    "$timestamp [$Level] $Message" | Out-File -FilePath "$LogPath\install.log" -Append
}

function Test-Prerequisites {
    Write-Log "Checking system prerequisites..." -Level Info

    # PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
        Write-Log "PowerShell 5.1+ required. Current: $psVersion" -Level Error
        return $false
    }
    Write-Log "PowerShell $psVersion ✓" -Level Success

    # Admin privileges check (not required but nice to know)
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    Write-Log "Running as $(if ($isAdmin) {'Administrator'} else {'Standard User'})" -Level Info

    # WinGet check
    $wingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
    if ($wingetPath) {
        Write-Log "WinGet found at: $wingetPath" -Level Success
        try {
            $wingetVersion = winget --version 2>$null
            Write-Log "WinGet version: $wingetVersion" -Level Info
        } catch {
            Write-Log "WinGet version check failed" -Level Warning
        }
    } else {
        Write-Log "WinGet not found. Some installations may use fallback methods." -Level Warning
    }

    # Chocolatey check
    $chocoPath = (Get-Command choco -ErrorAction SilentlyContinue).Source
    if ($chocoPath) {
        Write-Log "Chocolatey found at: $chocoPath" -Level Success
    }

    return $true
}

function Invoke-WithRetry {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [int]$MaxRetries = 3,

        [int]$RetryDelay = 2,

        [string]$ErrorMessage = "Operation failed after $MaxRetries attempts"
    )

    $attempt = 0
    $lastError = $null

    while ($attempt -le $MaxRetries) {
        try {
            $attempt++
            if ($attempt -gt 1) {
                Write-Log "Retry attempt $attempt of $MaxRetries..." -Level Warning
                Start-Sleep -Seconds $RetryDelay
            }

            return & $ScriptBlock
        } catch {
            $lastError = $_
            Write-Log "Attempt $attempt failed: $($_.Exception.Message)" -Level Warning

            if ($attempt -eq $MaxRetries) {
                throw "$ErrorMessage`: $lastError"
            }
        }
    }
}

function Add-ToPath {
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    $resolvedPath = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $resolvedPath) {
        Write-Log "Path not found: $Path" -Level Warning
        return
    }

    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($currentPath -notlike "*$resolvedPath*") {
        [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$resolvedPath", 'User')
        Write-Log "Added to user PATH: $resolvedPath" -Level Success
    } else {
        Write-Log "Already in PATH: $resolvedPath" -Level Info
    }
}
#endregion

#region Installation Methods
function Install-WithWinget {
    param(
        [Parameter(Mandatory)]
        [string]$Id,

        [string]$Name
    )

    if ($SkipWinget -or $FallbackOnly) {
        Write-Log "Skipping WinGet installation for $Name" -Level Info
        return $false
    }

    if ($WhatIf) {
        Write-Log "[WhatIf] Would install with WinGet: $Name ($Id)" -Level Info
        return $true
    }

    try {
        Write-Log "Installing $Name via WinGet..." -Level Info
        $output = winget install --id $Id --exact --accept-source-agreements --accept-package-agreements --silent
        Write-Log "WinGet installation successful for $Name" -Level Success
        return $true
    } catch {
        Write-Log "WinGet installation failed for ${Name}: $($_.Exception.Message)" -Level Warning
        return $false
    }
}

function Install-FromGitHub {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config,

        [string]$Name
    )

    $owner = $Config.Owner
    $repo = $Config.Repo
    $pattern = $Config.AssetPattern
    $extract = $Config.Extract
    $extractDir = $Config.ExtractDir

    if ($WhatIf) {
        Write-Log "[WhatIf] Would download from GitHub: ${Name} ($owner/$repo)" -Level Info
        return $true
    }

    try {
        Write-Log "Fetching latest release for $owner/$repo..." -Level Info

        # GitHub API call with retry
        $release = Invoke-WithRetry -ScriptBlock {
            $headers = @{
                'Accept' = 'application/vnd.github.v3+json'
                'User-Agent' = 'Terminal-Tools-Installer'
            }

            $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/releases" -Headers $headers
            $releases[0]  # Latest release
        } -ErrorMessage "Failed to fetch GitHub release for $owner/$repo"

        # Find matching asset
        $asset = $release.assets | Where-Object { $_.name -match $pattern } | Select-Object -First 1

        if (-not $asset) {
            throw "No asset matching pattern '$pattern' found in release $($release.tag_name)"
        }

        $downloadUrl = $asset.browser_download_url
        $fileName = Split-Path $downloadUrl -Leaf
        $filePath = Join-Path $DownloadPath $fileName

        Write-Log "Downloading: $fileName ($([math]::Round($asset.size/1MB, 2)) MB)" -Level Info

        # Download file
        Invoke-WebRequest -Uri $downloadUrl -OutFile $filePath -ErrorAction Stop

        Write-Log "Download completed: $filePath" -Level Success

        # Extract if needed
        if ($extract) {
            Write-Log "Extracting archive..." -Level Info

            $destDir = if ($extractDir) {
                Join-Path $DownloadPath $extractDir
            } else {
                Join-Path $DownloadPath $Name
            }

            Expand-Archive -Path $filePath -DestinationPath $destDir -Force
            Write-Log "Extracted to: $destDir" -Level Success

            # Cleanup archive if configured
            if (-not $ForceDownload) {
                Remove-Item $filePath -Force
            }
        }

        return $true
    } catch {
        Write-Log "GitHub download failed for ${Name}: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Install-FromDirectUrl {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config,

        [string]$Name
    )

    $url = $Config.Url
    $installer = $Config.Installer
    $args = $Config.Args
    $extract = $Config.Extract

    if ($WhatIf) {
        Write-Log "[WhatIf] Would download from direct URL: ${Name}" -Level Info
        return $true
    }

    try {
        Write-Log "Downloading ${Name} from direct URL..." -Level Info

        $filePath = Join-Path $DownloadPath $installer

        # Download file
        Invoke-WebRequest -Uri $url -OutFile $filePath -ErrorAction Stop

        Write-Log "Download completed: $filePath" -Level Success

        if ($extract) {
            Write-Log "Extracting archive..." -Level Info
            Expand-Archive -Path $filePath -DestinationPath $DownloadPath -Force
            Write-Log "Extracted to: $DownloadPath" -Level Success

            if (-not $ForceDownload) {
                Remove-Item $filePath -Force
            }
        } elseif ($args) {
            Write-Log "Running installer with arguments..." -Level Info
            Start-Process $filePath -ArgumentList $args -Wait -NoNewWindow
            Write-Log "Installation completed for ${Name}" -Level Success
        }

        return $true
    } catch {
        Write-Log "Direct download failed for ${Name}: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Install-WithChocolatey {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config,

        [string]$Name
    )

    $package = $Config.Package
    $args = $Config.Args

    if ($WhatIf) {
        Write-Log "[WhatIf] Would install with Chocolatey: ${Name} ($package)" -Level Info
        return $true
    }

    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey not installed. Skipping Chocolatey installation for ${Name}" -Level Warning
        return $false
    }

    try {
        Write-Log "Installing ${Name} via Chocolatey..." -Level Info

        $chocoArgs = @('install', $package, '-y', '--no-progress')
        if ($args) {
            $chocoArgs += $args
        }

        & choco @chocoArgs

        if ($LASTEXITCODE -eq 0) {
            Write-Log "Chocolatey installation successful for ${Name}" -Level Success
            return $true
        } else {
            throw "Chocolatey exited with code $LASTEXITCODE"
        }
    } catch {
        Write-Log "Chocolatey installation failed for ${Name}: $($_.Exception.Message)" -Level Error
        return $false
    }
}
#endregion

#region Main Installation Logic
function Install-Tool {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [hashtable]$Config
    )

    Write-Log "`n=== Processing: ${Name} ===" -Level Info

    $result = @{
        Name = $Name
        MethodsAttempted = @()
        Success = $false
        FinalMethod = $null
        Error = $null
        Timestamp = Get-Date
    }

    try {
        # Try WinGet first (unless skipped)
        if ($Config.WingetId -and (-not $SkipWinget -and -not $FallbackOnly) -and ($Method -in @('All', 'Winget'))) {
            $result.MethodsAttempted += 'Winget'
            if (Install-WithWinget -Id $Config.WingetId -Name $Name) {
                $result.Success = $true
                $result.FinalMethod = 'Winget'
                return $result
            }
        }

        # Try fallback methods in order
        $methods = $Config.Methods

        if ($Method -eq 'All') {
            $fallbackOrder = @('GitHub', 'Direct', 'Chocolatey')
        } else {
            $fallbackOrder = @($Method)
        }

        foreach ($method in $fallbackOrder) {
            if ($methods.$method) {
                $result.MethodsAttempted += $method

                # PowerShell 5.1 compatible switch statement
                $success = $false
                switch ($method) {
                    'GitHub' {
                        $success = Install-FromGitHub -Config $methods.GitHub -Name $Name
                    }
                    'Direct' {
                        $success = Install-FromDirectUrl -Config $methods.Direct -Name $Name
                    }
                    'Chocolatey' {
                        $success = Install-WithChocolatey -Config $methods.Chocolatey -Name $Name
                    }
                    default {
                        $success = $false
                    }
                }

                if ($success) {
                    $result.Success = $true
                    $result.FinalMethod = $method

                    # Add to PATH if binaries specified
                    if ($Config.Path -and $Config.Binaries) {
                        $toolPath = Join-Path $DownloadPath $Config.Path
                        Add-ToPath -Path $toolPath
                    }

                    return $result
                }
            }
        }

        # All methods failed
        $result.Error = "All installation methods failed"
        Write-Log "All installation methods failed for ${Name}" -Level Error

    } catch {
        $result.Error = $_.Exception.Message
        Write-Log "Installation failed for ${Name}: $($_.Exception.Message)" -Level Error
    }

    return $result
}

function Test-InstalledTools {
    param(
        [hashtable]$ToolsConfig
    )

    Write-Log "`n=== Verifying installations ===" -Level Info

    $verificationResults = @()

    foreach ($toolName in $ToolsConfig.Keys) {
        $config = $ToolsConfig[$toolName]

        if ($config.Binaries) {
            foreach ($binary in $config.Binaries) {
                $found = $false
                $version = "Not found"

                # Check in download directory
                $localPath = Join-Path $DownloadPath $binary
                if (Test-Path $localPath) {
                    $found = $true
                    try {
                        $fileInfo = Get-Item $localPath
                        $version = "v$($fileInfo.VersionInfo.FileVersion)"
                    } catch {
                        $version = "Present"
                    }
                }

                # Check in PATH
                if (-not $found) {
                    $pathResult = Get-Command $binary -ErrorAction SilentlyContinue
                    if ($pathResult) {
                        $found = $true
                        try {
                            & $binary --version 2>&1 | Select-Object -First 1 | ForEach-Object { $version = $_ }
                        } catch {
                            $version = "Present"
                        }
                    }
                }

                $verificationResults += [PSCustomObject]@{
                    Tool = $toolName
                    Binary = $binary
                    Installed = $found
                    Version = $version
                }
            }
        }
    }

    return $verificationResults
}

function Show-Summary {
    param(
        [array]$Results,
        [array]$VerificationResults,
        [datetime]$StartTime
    )

    $endTime = Get-Date
    $duration = $endTime - $StartTime

    Write-Log "`n========================================" -Level Info
    Write-Log "INSTALLATION SUMMARY" -Level Info
    Write-Log "========================================" -Level Info

    $successCount = ($Results | Where-Object { $_.Success }).Count
    $totalCount = $Results.Count

    Write-Log "Duration: $($duration.ToString('hh\:mm\:ss'))" -Level Info
    Write-Log "Tools processed: $totalCount" -Level Info
    Write-Log "Successfully installed: $successCount" -Level $(if ($successCount -eq $totalCount) { 'Success' } else { 'Warning' })

    Write-Log "`n--- Detailed Results ---" -Level Info
    foreach ($result in $Results) {
        $icon = if ($result.Success) { '✓' } else { '✗' }
        $color = if ($result.Success) { 'Green' } else { 'Red' }

        $methodInfo = if ($result.FinalMethod) {
            "via $($result.FinalMethod)"
        } else {
            "Failed after: $($result.MethodsAttempted -join ', ')"
        }

        Write-Host "  $icon $($result.Name.PadRight(20)) $methodInfo" -ForegroundColor $color
    }

    if ($VerificationResults) {
        $installedCount = ($VerificationResults | Where-Object { $_.Installed }).Count
        $totalBinaries = $VerificationResults.Count

        Write-Log "`n--- Verification ---" -Level Info
        Write-Log "Binaries found: $installedCount/$totalBinaries" -Level $(if ($installedCount -eq $totalBinaries) { 'Success' } else { 'Warning' })

        foreach ($verify in $VerificationResults | Where-Object { -not $_.Installed }) {
            Write-Log "Missing: $($verify.Tool) - $($verify.Binary)" -Level Warning
        }
    }

    Write-Log "`nLog file: $LogPath\install.log" -Level Info
    Write-Log "Download directory: $DownloadPath" -Level Info

    if ($successCount -lt $totalCount) {
        Write-Log "`nSome tools failed to install. Check the log for details." -Level Warning
        Write-Log "You can retry with: .\terminal-tools.ps1 -FallbackOnly" -Level Info
    } else {
        Write-Log "`nAll tools installed successfully! You may need to restart your terminal for PATH changes to take effect." -Level Success
    }
}
#endregion

#region Main Execution
function Main {
    # Create directories
    if (-not (Test-Path $DownloadPath)) {
        New-Item -ItemType Directory -Path $DownloadPath -Force | Out-Null
        Write-Log "Created download directory: $DownloadPath" -Level Success
    }

    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        Write-Log "Created log directory: $LogPath" -Level Success
    }

    # Banner
    Write-Host @"

    ╔═══════════════════════════════════════╗
    ║    Terminal Tools Installer v2.0     ║
    ║                                       ║
    ║  Multi-method installation with       ║
    ║  comprehensive fallback strategies    ║
    ╚═══════════════════════════════════════╝

"@ -ForegroundColor Cyan

    Write-Log "Starting installation at $(Get-Date)" -Level Info
    Write-Log "Parameters:" -Level Info
    Write-Log "  Download Path: $DownloadPath" -Level Info
    Write-Log "  Method: $Method" -Level Info
    Write-Log "  SkipWinget: $SkipWinget" -Level Info
    Write-Log "  ForceDownload: $ForceDownload" -Level Info
    Write-Log "  WhatIf: $WhatIf" -Level Info

    # Check prerequisites
    if (-not (Test-Prerequisites)) {
        Write-Log "Prerequisites check failed. Exiting." -Level Error
        exit 1
    }

    # Filter tools based on parameters
    $toolsToInstall = if ($Method -ne 'All') {
        $ToolsConfig.Keys | Where-Object {
            $config = $ToolsConfig[$_]
            ($Method -eq 'Winget' -and $config.WingetId) -or
            ($Method -eq 'GitHub' -and $config.Methods.GitHub) -or
            ($Method -eq 'Direct' -and $config.Methods.Direct) -or
            ($Method -eq 'Chocolatey' -and $config.Methods.Chocolatey)
        }
    } else {
        $ToolsConfig.Keys
    }

    if (-not $toolsToInstall) {
        Write-Log "No tools match the selected method: $Method" -Level Warning
        exit 1
    }

    Write-Log "`nInstalling $($toolsToInstall.Count) tools..." -Level Info

    # Install tools
    $installationResults = @()
    foreach ($toolName in $toolsToInstall) {
        $result = Install-Tool -Name $toolName -Config $ToolsConfig[$toolName]
        $installationResults += $result

        # Small delay to avoid rate limiting
        Start-Sleep -Milliseconds 500
    }

    # Verify installations
    $verificationResults = Test-InstalledTools -ToolsConfig $ToolsConfig

    # Show summary
    Show-Summary -Results $installationResults -VerificationResults $verificationResults -StartTime $global:StartTime

    # Export results to JSON
    $exportData = @{
        Metadata = @{
            Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            Duration = "$($duration.ToString('hh\:mm\:ss'))"
            Parameters = @{
                DownloadPath = $DownloadPath
                Method = $Method
                SkipWinget = $SkipWinget
                ForceDownload = $ForceDownload
            }
        }
        Results = $installationResults
        Verification = $verificationResults
    }

    $exportData | ConvertTo-Json -Depth 5 | Out-File "$LogPath\results.json"
    Write-Log "Detailed results saved to: $LogPath\results.json" -Level Info

    # Return success if all tools installed
    $failedTools = $installationResults | Where-Object { -not $_.Success } | ForEach-Object { $_.Name }
    if ($failedTools) {
        exit 1
    }
}

# Entry point
try {
    Main
} catch {
    Write-Log "Fatal error: $($_.Exception.Message)" -Level Error
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
#endregion
