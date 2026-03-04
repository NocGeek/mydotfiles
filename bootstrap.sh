#!/usr/bin/env bash
set -euo pipefail

REPO_SSH="git@github.com:NocGeek/mydotfiles.git"
TARGET_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

echo "[*] Bootstrapping dotfiles into: $TARGET_DIR"

# --- 1) Install prerequisites (best-effort) ---
install_prereqs_debian() {
  echo "[*] Installing prerequisites (Debian/Ubuntu)..."
  sudo apt update
  sudo apt install -y git curl ca-certificates
}

install_prereqs_fedora() {
  echo "[*] Installing prerequisites (Fedora/RHEL)..."
  sudo dnf install -y git curl ca-certificates
}

install_prereqs_arch() {
  echo "[*] Installing prerequisites (Arch)..."
  sudo pacman -Sy --noconfirm git curl ca-certificates
}

install_prereqs_macos() {
  echo "[*] macOS detected."
  if ! command -v git >/dev/null 2>&1; then
    echo "[!] git not found. Installing Xcode Command Line Tools..."
    xcode-select --install || true
    echo "[*] Re-run bootstrap after tools finish installing."
    exit 1
  fi
  if ! command -v curl >/dev/null 2>&1; then
    echo "[!] curl not found (unexpected on macOS)."
    exit 1
  fi
}

need_git=0
need_curl=0
command -v git >/dev/null 2>&1 || need_git=1
command -v curl >/dev/null 2>&1 || need_curl=1

if (( need_git == 1 || need_curl == 1 )); then
  if command -v apt >/dev/null 2>&1; then
    install_prereqs_debian
  elif command -v dnf >/dev/null 2>&1; then
    install_prereqs_fedora
  elif command -v pacman >/dev/null 2>&1; then
    install_prereqs_arch
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    install_prereqs_macos
  else
    echo "[!] Could not detect package manager to install prerequisites."
    echo "    Please install git and curl, then re-run."
    exit 1
  fi
else
  echo "[*] Prerequisites already present (git, curl)."
fi

# --- 2) Clone or update repo ---
if [ -d "$TARGET_DIR/.git" ]; then
  echo "[*] Repo already exists; updating..."
  git -C "$TARGET_DIR" fetch --all --prune
  git -C "$TARGET_DIR" pull --rebase
else
  echo "[*] Cloning repo..."
  git clone "$REPO_SSH" "$TARGET_DIR"
fi

# --- 3) Run installer ---
echo "[*] Running installer..."
cd "$TARGET_DIR"
chmod +x ./install.sh
./install.sh

echo
echo "[✓] Bootstrap complete."
echo "    Open a new terminal or run: exec zsh"
