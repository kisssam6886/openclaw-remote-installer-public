$ErrorActionPreference = 'Stop'
if (-not $env:OPENCLAW_INSTALL_SOURCE) { $env:OPENCLAW_INSTALL_SOURCE = 'public-mirror' }
if (-not $env:OPENCLAW_INSTALL_ARCHIVE_URL) { $env:OPENCLAW_INSTALL_ARCHIVE_URL = 'https://raw.githubusercontent.com/kisssam6886/openclaw-remote-installer-public/main/releases/openclaw-remote-installer-main.zip' }
irm https://raw.githubusercontent.com/kisssam6886/openclaw-remote-installer-public/main/bootstrap/source-remote-install.ps1 | iex
