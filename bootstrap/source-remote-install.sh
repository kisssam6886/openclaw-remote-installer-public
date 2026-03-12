#!/usr/bin/env bash
set -euo pipefail

OPENCLAW_INSTALL_REPO="${OPENCLAW_INSTALL_REPO:-kisssam6886/openclaw-remote-installer}"
OPENCLAW_INSTALL_REF="${OPENCLAW_INSTALL_REF:-main}"
OPENCLAW_INSTALL_ARCHIVE_URL="${OPENCLAW_INSTALL_ARCHIVE_URL:-https://github.com/${OPENCLAW_INSTALL_REPO}/archive/refs/heads/${OPENCLAW_INSTALL_REF}.tar.gz}"
OPENCLAW_INSTALL_SOURCE="${OPENCLAW_INSTALL_SOURCE:-github-archive}"
WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/openclaw-remote-installer.XXXXXX")"
ARCHIVE_FILE="$WORKDIR/repo.tar.gz"

cleanup() {
  if [ "${OPENCLAW_KEEP_INSTALLER_WORKDIR:-false}" = "true" ]; then
    echo "[Remote Install] Installer workdir kept at: $WORKDIR"
    return
  fi

  rm -rf "$WORKDIR"
}

fetch_archive() {
  local url="$1"
  local target="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$target"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "$target" "$url"
    return
  fi

  echo "curl or wget is required for remote install."
  exit 1
}

trap cleanup EXIT

echo "[Remote Install] Downloading installer archive..."
fetch_archive "$OPENCLAW_INSTALL_ARCHIVE_URL" "$ARCHIVE_FILE"

echo "[Remote Install] Extracting installer archive..."
tar -xzf "$ARCHIVE_FILE" -C "$WORKDIR"

if [ -f "$WORKDIR/bootstrap/macos.sh" ]; then
  REPO_DIR="$WORKDIR"
else
  REPO_DIR="$(find "$WORKDIR" -mindepth 1 -maxdepth 1 -type d | while read -r candidate; do
    if [ -f "$candidate/bootstrap/macos.sh" ]; then
      printf '%s
' "$candidate"
      break
    fi
  done)"
fi

if [ -z "$REPO_DIR" ] || [ ! -f "$REPO_DIR/bootstrap/macos.sh" ]; then
  echo "Failed to locate extracted installer directory."
  exit 1
fi

export OPENCLAW_INSTALL_SOURCE

cd "$REPO_DIR"
echo "[Remote Install] Running macOS bootstrap from $REPO_DIR"
bash "$REPO_DIR/bootstrap/macos.sh"
