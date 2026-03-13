$ErrorActionPreference = 'Stop'

$psMajor = 2
if ($PSVersionTable -and $PSVersionTable.PSVersion) { $psMajor = [int]$PSVersionTable.PSVersion.Major }
if ($psMajor -lt 5) { throw "当前 Windows PowerShell 版本过旧（检测到 $psMajor）。Windows 安装主链当前要求 Windows PowerShell 5.1+ 或 PowerShell 7。请先升级 PowerShell，再重试。" }

$repo = if ($env:OPENCLAW_INSTALL_REPO) { $env:OPENCLAW_INSTALL_REPO } else { 'kisssam6886/openclaw-remote-installer' }
$ref = if ($env:OPENCLAW_INSTALL_REF) { $env:OPENCLAW_INSTALL_REF } else { 'main' }
$archiveUrl = if ($env:OPENCLAW_INSTALL_ARCHIVE_URL) { $env:OPENCLAW_INSTALL_ARCHIVE_URL } else { "https://github.com/$repo/archive/refs/heads/$ref.zip" }
if (-not $env:OPENCLAW_INSTALL_SOURCE) { $env:OPENCLAW_INSTALL_SOURCE = 'github-archive' }

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("openclaw-remote-installer-{0}" -f ([guid]::NewGuid().ToString('N')))
$zipPath = Join-Path $tempRoot 'repo.zip'

function Cleanup-InstallerRoot {
    if ($env:OPENCLAW_KEEP_INSTALLER_WORKDIR -eq 'true') {
        Write-Host "[Remote Install] Installer workdir kept at: $tempRoot"
        return
    }

    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
    }
}

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    Write-Host '[Remote Install] Downloading installer archive...'
    Invoke-WebRequest -Uri $archiveUrl -OutFile $zipPath

    Write-Host '[Remote Install] Extracting installer archive...'
    Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

    $repoDir = $null
    if (Test-Path (Join-Path $tempRoot 'bootstrap/windows.ps1')) {
        $repoDir = Get-Item $tempRoot
    }
    else {
        $repoDir = Get-ChildItem -Path $tempRoot -Directory | Where-Object {
            Test-Path (Join-Path $_.FullName 'bootstrap/windows.ps1')
        } | Select-Object -First 1
    }

    if (-not $repoDir) {
        throw 'Failed to locate extracted installer directory.'
    }

    Write-Host "[Remote Install] Running Windows bootstrap from $($repoDir.FullName)"
    & powershell -ExecutionPolicy Bypass -File (Join-Path $repoDir.FullName 'bootstrap/windows.ps1')
}
finally {
    Cleanup-InstallerRoot
}
