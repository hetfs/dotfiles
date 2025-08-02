#!/usr/bin/env bash

set -euo pipefail

# ─────────────────────────────────────────────────────────────
# ⚙️ Config
# ─────────────────────────────────────────────────────────────
FORCE=false
VERBOSE=false
INSTALL_COLLECTIONS=false
LOGFILE=""
PLATFORM=""

# ─────────────────────────────────────────────────────────────
# 🧠 Help
# ─────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Install Ansible roles (and optionally collections) for both common and platform-specific configs.

Options:
  --force           Force reinstall roles even if already installed
  --collections     Also install Ansible Galaxy collections
  --verbose         Show detailed installation logs
  --log <file>      Log output to a file
  -h, --help        Show this help message

Examples:
  $0 --collections
  $0 --force --log install.log
EOF
}

# ─────────────────────────────────────────────────────────────
# 🧠 Platform Detection
# ─────────────────────────────────────────────────────────────
detect_platform() {
  local unameOut
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*)
    if grep -qi microsoft /proc/version; then
      echo "wsl"
    elif [ -f /etc/arch-release ]; then
      echo "arch"
    elif grep -qi ubuntu /etc/lsb-release 2>/dev/null; then
      echo "ubuntu"
    else echo "linux"; fi
    ;;
  Darwin*) echo "darwin" ;;
  CYGWIN* | MINGW* | MSYS*) echo "windows" ;;
  *) echo "unknown" ;;
  esac
}

# ─────────────────────────────────────────────────────────────
# 🚀 Install Roles & Collections
# ─────────────────────────────────────────────────────────────
install_from_file() {
  local file=$1
  local type=$2 # 'role' or 'collection'
  local cmd="ansible-galaxy"

  [[ "$VERBOSE" = true ]] && echo "🔍 Checking $file for $type install"

  if [[ -f "$file" ]]; then
    if [[ "$type" == "role" ]]; then
      [[ "$VERBOSE" = true ]] && echo "📦 Installing roles from $file"
      $cmd role install -r "$file" ${FORCE:+--force}
    else
      [[ "$VERBOSE" = true ]] && echo "📚 Installing collections from $file"
      $cmd collection install -r "$file" ${FORCE:+--force}
    fi
  else
    [[ "$VERBOSE" = true ]] && echo "⚠️  No $type requirements found at: $file"
  fi
}

# ─────────────────────────────────────────────────────────────
# 🧩 Parse Arguments
# ─────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
  --force) FORCE=true ;;
  --collections) INSTALL_COLLECTIONS=true ;;
  --verbose) VERBOSE=true ;;
  --log)
    shift
    LOGFILE="$1"
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "❌ Unknown option: $1"
    usage
    exit 1
    ;;
  esac
  shift
done

# ─────────────────────────────────────────────────────────────
# 🏁 Main logic
# ─────────────────────────────────────────────────────────────
PLATFORM=$(detect_platform)
[[ "$PLATFORM" == "unknown" ]] && echo "❌ Unsupported platform" && exit 1

[[ "$VERBOSE" = true ]] && echo "👉 Detected platform: $PLATFORM"

# Optionally tee output to logfile
exec > >(tee -a "${LOGFILE:-/dev/stdout}") 2>&1

# Shared roles
install_from_file "./common/requirements.yml" role
$INSTALL_COLLECTIONS && install_from_file "./common/collections.yml" collection

# Platform-specific roles
install_from_file "./$PLATFORM/requirements.yml" role
$INSTALL_COLLECTIONS && install_from_file "./$PLATFORM/collections.yml" collection

echo "✅ Ansible roles${INSTALL_COLLECTIONS:+ and collections} installed successfully for: $PLATFORM"
