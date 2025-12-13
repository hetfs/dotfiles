# Terminal Tools Installer

## Overview

The Terminal Tools Installer is a robust PowerShell script designed to automate the installation of essential command-line tools on Windows systems. It features a multi-method installation approach with comprehensive fallback strategies, ensuring maximum success rates even in challenging network or system environments.

## Features

- **Multi-method Installation**: Supports WinGet, GitHub releases, direct downloads, and Chocolatey
- **Intelligent Fallback**: Automatically tries alternative methods if primary installation fails
- **Comprehensive Logging**: Detailed logs and JSON export for troubleshooting
- **Idempotent Operations**: Won't re-download or re-install unless explicitly forced
- **PATH Management**: Automatically adds installed tools to system PATH
- **Verification System**: Post-installation verification of all tools
- **Modular Design**: Easy to add new tools or installation methods

## Prerequisites

- **Windows 10/11** or **Windows Server 2016+**
- **PowerShell 5.1** or higher
- **Administrator privileges** (recommended for system-wide installation)
- **Internet connectivity** for downloading tools

### Optional Dependencies
- **WinGet**: For primary installation method (auto-detected)
- **Chocolatey**: As a fallback method (auto-detected)
- **7-Zip**: For extracting archives (built-in PowerShell 5.1 methods used)

## Quick Start

### Basic Installation
```powershell
# Run with default settings
.\terminal-tools.ps1

# Install to custom directory
.\terminal-tools.ps1 -DownloadPath "C:\tools"

# Skip WinGet and use fallback methods only
.\terminal-tools.ps1 -SkipWinget
```

### Test Run
```powershell
# Dry run - shows what would be installed
.\terminal-tools.ps1 -WhatIf

# Test with specific installation method
.\terminal-tools.ps1 -Method GitHub -WhatIf
```

## Installation Methods

The script attempts installation methods in this order:

1. **WinGet** (Primary): Uses Microsoft's package manager
2. **GitHub Releases**: Downloads from official GitHub repositories
3. **Direct Downloads**: Downloads from official project websites
4. **Chocolatey**: Uses Chocolatey package manager as last resort

### Method Comparison

| Method | Speed | Reliability | System Impact |
|--------|-------|-------------|---------------|
| WinGet | ⚡ Fast | High | Minimal |
| GitHub | 🐢 Variable | High | Files only |
| Direct | 🐢 Variable | Medium | Files only |
| Chocolatey | ⚡ Fast | High | Package manager |

## Tool Catalog

### Core Development Tools
- **Git**: Distributed version control
- **Neovim**: Modern Vim-based text editor
- **VSCode**: Source code editor
- **GitHub CLI**: GitHub command-line interface
- **LazyGit**: Terminal UI for Git

### File Search & Navigation
- **Ripgrep (rg)**: Ultra-fast file search
- **Fd**: Simple, fast file finder
- **Fzf**: Fuzzy finder
- **Zoxide**: Smarter cd command
- **Tre**: Tree command with Git integration

### Terminal Enhancement
- **Starship**: Minimal, blazing-fast prompt
- **Eza**: Modern ls replacement
- **Gsudo**: Sudo for Windows
- **Fastfetch**: System information tool
- **Bottom**: System monitor (btm)

### Text Processing
- **Bat**: Cat with syntax highlighting
- **Delta**: Git diff viewer
- **Glow**: Markdown viewer
- **Vale**: Linter for prose
- **Silver Searcher (ag)**: Code search tool

### Utilities
- **Tldr**: Simplified man pages
- **Yazi**: Terminal file manager
- **MiKTeX**: LaTeX distribution
- **Lua**: Programming language
- **Globalping**: Network diagnostic tool

## Usage Guide

### Command Line Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `-DownloadPath` | Installation directory | `%USERPROFILE%\bin` |
| `-LogPath` | Log file directory | `%TEMP%\terminal-tools-logs` |
| `-SkipWinget` | Skip WinGet installation | `$false` |
| `-FallbackOnly` | Use only fallback methods | `$false` |
| `-ForceDownload` | Force re-download files | `$false` |
| `-WhatIf` | Simulation mode | `$false` |
| `-Method` | Specific installation method | `All` |
| `-MaxConcurrentDownloads` | Parallel download limit | `3` |

### Common Usage Patterns

#### Developer Setup
```powershell
# Complete developer environment
.\terminal-tools.ps1 -DownloadPath "C:\dev\tools"

# Core tools only
$devTools = @('Git', 'Neovim', 'VSCode', 'GitHubCLI', 'LazyGit')
foreach ($tool in $devTools) {
    .\terminal-tools.ps1 -Method Winget -WhatIf | Select-String $tool
}
```

#### System Administrator Setup
```powershell
# Admin tools with logging
.\terminal-tools.ps1 -Method All -LogPath "C:\Admin\Logs" *> "C:\Admin\install.log"

# Network diagnostic tools
$netTools = @('Globalping', 'Gsudo', 'Fastfetch')
$netTools | ForEach-Object { .\terminal-tools.ps1 -SkipWinget }
```

#### Batch Operations
```powershell
# Install in batches
$batch1 = @('Git', 'Neovim', 'Ripgrep', 'Fd', 'Fzf')
$batch2 = @('Bat', 'Delta', 'Starship', 'Zoxide', 'Tldr')

$batch1 | ForEach-Object { .\terminal-tools.ps1 -Method Winget }
$batch2 | ForEach-Object { .\terminal-tools.ps1 -Method GitHub }
```

## Configuration

### Custom Tool Configuration

You can extend the tool list by modifying the `$ToolsConfig` hashtable in the script:

```powershell
# Example: Adding a custom tool
$ToolsConfig['MyTool'] = @{
    WingetId = 'Vendor.Tool'
    Methods = @{
        Winget = $true
        GitHub = @{
            Owner = 'owner'
            Repo = 'repo'
            AssetPattern = '.*windows.*zip$'
            Extract = $true
        }
    }
    Binaries = @('mytool.exe')
    Path = '.'
}
```

### Environment Variables

The script respects these environment variables:
- `TERMINAL_TOOLS_DIR`: Overrides default download path
- `TERMINAL_TOOLS_LOG`: Overrides default log path
- `NO_WINGET`: Skips WinGet (equivalent to `-SkipWinget`)
- `FORCE_DOWNLOAD`: Forces re-download (equivalent to `-ForceDownload`)

## Output Structure

### Generated Directories
```
%USERPROFILE%\bin\                    # Installed tools
├── Git\                             # Git installation
├── nvim\                            # Neovim installation
├── lazygit\                         # LazyGit binary
└── *.exe                            # Other standalone tools

%TEMP%\terminal-tools-logs\          # Log files
├── install.log                      # Detailed installation log
├── results.json                     # JSON results export
├── verification.md                  # Installation verification
└── errors.log                       # Error details (if any)
```

### Log Files

1. **install.log**: Chronological log of all operations
2. **results.json**: Machine-readable installation results
3. **verification.md**: Human-readable verification report
4. **errors.log**: Aggregated error information

## Troubleshooting

### Common Issues

#### "WinGet not found"
```powershell
# Check if WinGet is installed
Get-Command winget -ErrorAction SilentlyContinue

# Install WinGet (requires Admin)
# From Microsoft Store or: https://aka.ms/getwinget
```

#### "Access denied" errors
```powershell
# Run as Administrator
Start-Process powershell -Verb RunAs -ArgumentList "-File .\terminal-tools.ps1"

# Or use gsudo if already installed
gsudo .\terminal-tools.ps1
```

#### Network/timeout issues
```powershell
# Use direct downloads only
.\terminal-tools.ps1 -Method Direct

# Increase timeout and retry
.\terminal-tools.ps1 -MaxConcurrentDownloads 1
```

#### PATH not updated
```powershell
# Refresh environment variables
refreshenv

# Or restart PowerShell
# Check if PATH contains your tools directory
$env:PATH -split ';' | Select-String "bin"
```

### Diagnostic Commands

```powershell
# Check installation status
Get-Command git, nvim, rg, fd, fzf -ErrorAction SilentlyContinue

# View installation logs
Get-Content "$env:TEMP\terminal-tools-logs\install.log" -Tail 50

# Verify tool versions
& git --version
& nvim --version
& rg --version

# Check disk space
Get-PSDrive C | Select-Object Used,Free
```

### Recovery Procedures

#### Reinstall failed tools
```powershell
# Identify failed installations
$results = Get-Content "$env:TEMP\terminal-tools-logs\results.json" | ConvertFrom-Json
$failed = $results.Results | Where-Object { -not $_.Success }
$failed | ForEach-Object {
    Write-Host "Reinstalling $($_.Name)..."
    .\terminal-tools.ps1 -FallbackOnly -WhatIf
}
```

#### Clean installation
```powershell
# Remove all installed tools
Remove-Item "$env:USERPROFILE\bin\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear logs
Remove-Item "$env:TEMP\terminal-tools-logs" -Recurse -Force -ErrorAction SilentlyContinue

# Fresh install
.\terminal-tools.ps1 -ForceDownload
```

## Performance Tips

### Parallel Downloads
```powershell
# Adjust based on network capability
.\terminal-tools.ps1 -MaxConcurrentDownloads 5  # Fast network
.\terminal-tools.ps1 -MaxConcurrentDownloads 1  # Slow/unstable network
```

### Caching Strategy
```powershell
# First run: Download everything
.\terminal-tools.ps1 -ForceDownload

# Subsequent runs: Use cached files
.\terminal-tools.ps1  # Will skip existing downloads
```

### Selective Installation
```powershell
# Install only what you need
$essentialTools = @('Git', 'Neovim', 'Ripgrep', 'Fd', 'Fzf')
$essentialTools | ForEach-Object {
    .\terminal-tools.ps1 -Method Winget -WhatIf | Where-Object { $_ -match $_ }
}
```

## Security Considerations

### Certificate Validation
- All GitHub downloads use HTTPS with certificate validation
- Direct downloads from official sources only
- Optional checksum verification (implement checksums in configuration)

### Permission Model
- User-level installation by default (no Admin required)
- System-wide installation available via `-DownloadPath` parameter
- PATH modifications at user level only

### Audit Trail
```powershell
# Review installation sources
Get-Content "$env:TEMP\terminal-tools-logs\results.json" |
    ConvertFrom-Json |
    Select-Object -ExpandProperty Results |
    Format-Table Name, FinalMethod, Success
```

## Integration Guide

### With Configuration Management
```powershell
# Ansible integration
- name: Install terminal tools
  win_shell: |
    .\terminal-tools.ps1 -DownloadPath "C:\ProgramData\Tools" -SkipWinget
  args:
    chdir: "{{ playbook_dir }}/scripts"

# PowerShell DSC configuration
Configuration TerminalTools {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Script InstallTerminalTools {
        GetScript = { @{ Result = (Test-Path "C:\tools") } }
        SetScript = {
            .\terminal-tools.ps1 -DownloadPath "C:\tools" -SkipWinget
        }
        TestScript = { Test-Path "C:\tools\git.exe" }
    }
}
```

### CI/CD Pipeline Integration
```yaml
# GitHub Actions
jobs:
  setup-tools:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install terminal tools
        shell: pwsh
        run: |
          .\terminal-tools.ps1 -DownloadPath "$env:RUNNER_TOOL_CACHE\tools"
          echo "C:\tools" | Out-File -FilePath $env:GITHUB_PATH -Append

# Azure DevOps
steps:
- pwsh: |
    .\terminal-tools.ps1 -DownloadPath "$(Agent.ToolsDirectory)\tools"
    Write-Host "##vso[task.prependpath]$(Agent.ToolsDirectory)\tools"
  displayName: 'Install terminal tools'
```

### Custom Script Integration
```powershell
# Include in your setup script
function Install-DevelopmentEnvironment {
    param([string]$ToolsPath = "$env:USERPROFILE\.tools")

    # Create tools directory
    New-Item -ItemType Directory -Path $ToolsPath -Force | Out-Null

    # Install terminal tools
    & "$PSScriptRoot\terminal-tools.ps1" -DownloadPath $ToolsPath -SkipWinget

    # Additional setup
    # ... your custom setup code ...
}

# Export as module
Export-ModuleMember -Function Install-DevelopmentEnvironment
```

## Maintenance

### Updating Tools
```powershell
# Force update all tools
.\terminal-tools.ps1 -ForceDownload

# Update specific tool
function Update-Tool {
    param([string]$ToolName)

    # Remove old version
    $toolConfig = $ToolsConfig[$ToolName]
    if ($toolConfig.Binaries) {
        $toolConfig.Binaries | ForEach-Object {
            Remove-Item (Join-Path $DownloadPath $_) -Force -ErrorAction SilentlyContinue
        }
    }

    # Reinstall
    Install-Tool -Name $ToolName -Config $toolConfig
}
```

### Monitoring Script Health
```powershell
# Check script dependencies
Test-Prerequisites

# Verify GitHub API access
try {
    Invoke-RestMethod -Uri "https://api.github.com/rate_limit" -Headers @{'Accept'='application/vnd.github.v3+json'}
} catch {
    Write-Warning "GitHub API may be rate limited"
}

# Disk space check
$requiredSpace = 2GB  # Estimated for all tools
$availableSpace = (Get-PSDrive C).Free
if ($availableSpace -lt $requiredSpace) {
    Write-Warning "Insufficient disk space. Required: $([math]::Round($requiredSpace/1GB,2))GB, Available: $([math]::Round($availableSpace/1GB,2))GB"
}
```

## Contributing

### Adding New Tools
1. Add tool configuration to `$ToolsConfig` hashtable
2. Include multiple installation methods when possible
3. Specify binary names for PATH addition
4. Test with `-WhatIf` flag before committing

### Reporting Issues
1. Check existing logs in `%TEMP%\terminal-tools-logs\`
2. Include PowerShell version: `$PSVersionTable.PSVersion`
3. Specify parameters used
4. Attach relevant log snippets

### Feature Requests
- [ ] Scoop package manager support
- [ ] Winget REST API integration for faster queries
- [ ] Progress bars for large downloads
- [ ] Checksum verification for all downloads
- [ ] Offline installation support

## Support

### Getting Help
- **Documentation**: This README
- **Issues**: GitHub issue tracker
- **Debugging**: Use `-WhatIf` and examine log files

### Community Resources
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [WinGet Package Repository](https://github.com/microsoft/winget-pkgs)
- [Chocolatey Community Packages](https://community.chocolatey.org/packages)

## License

This script is provided under the MIT License. Use at your own risk in production environments.

## Version History

- **v2.0**: PowerShell 5.1 compatible, comprehensive fallback strategies
- **v1.0**: Initial release with basic WinGet and GitHub support

## Acknowledgments

- Microsoft for WinGet and PowerShell
- GitHub for API access to releases
- All open-source tool maintainers
- Chocolatey team for package management

---

*Last Updated: $(Get-Date -Format 'yyyy-MM-dd')*
*For updates and issues, check the repository.*
