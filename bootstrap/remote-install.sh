#!/usr/bin/env bash
set -euo pipefail
OPENCLAW_INSTALL_SOURCE="${OPENCLAW_INSTALL_SOURCE:-public-mirror}"
OPENCLAW_INSTALL_ARCHIVE_URL="${OPENCLAW_INSTALL_ARCHIVE_URL:-https://raw.githubusercontent.com/kisssam6886/openclaw-remote-installer-public/main/releases/openclaw-remote-installer-main.tar.gz}"
export OPENCLAW_INSTALL_SOURCE OPENCLAW_INSTALL_ARCHIVE_URL
curl -fsSL "https://raw.githubusercontent.com/kisssam6886/openclaw-remote-installer-public/main/bootstrap/source-remote-install.sh" | bash
