#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Repo: $REPO_DIR"

###############################################################################
# Create stable ~/.dotfiles link
###############################################################################

ln -snf "$REPO_DIR" "$HOME/.dotfiles"

###############################################################################
# Install packages
###############################################################################

if command -v apt >/dev/null 2>&1; then
  echo "[*] Installing base packages..."

  sudo apt update
  sudo apt install -y \
    zsh git curl \
    tmux rsync btop \
    fzf ripgrep jq xclip \
    fd-find \
    bat \
    eza \
    zoxide \
    unzip
fi

###############################################################################
# Install Nerd Fonts (MesloLGS for Powerlevel10k)
###############################################################################

FONT_DIR="$HOME/.local/share/fonts"

if [ ! -d "$FONT_DIR/MesloLGS_NF" ]; then
  echo "[*] Installing MesloLGS Nerd Font..."

  mkdir -p "$FONT_DIR/MesloLGS_NF"
  TMP_DIR="$(mktemp -d)"

  cd "$TMP_DIR"

  curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip

  unzip Meslo.zip -d "$FONT_DIR/MesloLGS_NF"

  fc-cache -fv >/dev/null

  cd ~
  rm -rf "$TMP_DIR"

  echo "[*] Nerd Font installed."
else
  echo "[*] Nerd Font already installed."
fi

###############################################################################
# Install Oh-My-Zsh
###############################################################################

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[*] Installing Oh-My-Zsh..."

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[*] Oh-My-Zsh already present."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

###############################################################################
# Install Powerlevel10k
###############################################################################

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "[*] Installing Powerlevel10k..."

  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "[*] Powerlevel10k already present."
fi

###############################################################################
# Install plugins
###############################################################################

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "[*] Installing zsh-autosuggestions..."

  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "[*] Installing zsh-syntax-highlighting..."

  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

###############################################################################
# Link configs
###############################################################################

echo "[*] Linking configs..."

ln -sf "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

###############################################################################
# Ensure scripts executable
###############################################################################

chmod +x "$REPO_DIR/bin/"* 2>/dev/null || true

###############################################################################
# Fix Debian command naming
###############################################################################

mkdir -p "$HOME/.local/bin"

if ! command -v bat >/dev/null && command -v batcat >/dev/null; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

###############################################################################
# Set default shell
###############################################################################

if command -v chsh >/dev/null 2>&1; then
  if [ "${SHELL:-}" != "/usr/bin/zsh" ] && [ -x /usr/bin/zsh ]; then
    echo "[*] Setting default shell to zsh..."
    chsh -s /usr/bin/zsh || true
  fi
fi

echo
echo "[✓] Environment installed."
echo "[✓] Restart your terminal or run: exec zsh"
