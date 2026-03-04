#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[*] Repo: $REPO_DIR"

###############################################################################
# Stable path for scripts (tmux uses ~/.dotfiles)
###############################################################################
ln -snf "$REPO_DIR" "$HOME/.dotfiles"

###############################################################################
# Install packages
###############################################################################
if command -v apt >/dev/null 2>&1; then
  echo "[*] Installing base packages..."

  sudo apt update
  sudo apt install -y \
    zsh git curl ca-certificates \
    tmux rsync btop \
    fzf ripgrep jq xclip \
    fd-find \
    bat \
    eza \
    zoxide \
    unzip \
    fontconfig
fi

###############################################################################
# Link configs EARLY (prevents zsh-newuser-install if anything later fails)
###############################################################################
echo "[*] Linking configs..."
ln -sf "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

###############################################################################
# Install Nerd Fonts (MesloLGS for Powerlevel10k)
###############################################################################
FONT_DIR="$HOME/.local/share/fonts"
MESLO_DIR="$FONT_DIR/MesloLGS_NF"

if [ ! -d "$MESLO_DIR" ]; then
  echo "[*] Installing MesloLGS Nerd Font..."
  mkdir -p "$MESLO_DIR"
  TMP_DIR="$(mktemp -d)"
  (
    cd "$TMP_DIR"
    curl -fL -o Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
    unzip -q Meslo.zip -d "$MESLO_DIR"
  )
  rm -rf "$TMP_DIR"

  # Refresh font cache if available (should be, due to fontconfig)
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -fv >/dev/null 2>&1 || true
  fi

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
else
  echo "[*] zsh-autosuggestions already present."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "[*] Installing zsh-syntax-highlighting..."
  git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "[*] zsh-syntax-highlighting already present."
fi

###############################################################################
# Ensure helper scripts executable
###############################################################################
chmod +x "$REPO_DIR/bin/"* 2>/dev/null || true

###############################################################################
# Debian naming compatibility shims (only if needed)
###############################################################################
mkdir -p "$HOME/.local/bin"

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
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
