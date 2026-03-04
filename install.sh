#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[*] Repo: $REPO_DIR"

# --- 1) Install packages (Debian/Ubuntu) ---
if command -v apt >/dev/null 2>&1; then
  echo "[*] Installing base packages via apt..."
  sudo apt update
  sudo apt install -y \
    zsh git curl \
    tmux rsync btop \
    fzf ripgrep jq xclip \
    fd-find \
    bat || true

  # Optional on some repos (don't fail if missing)
  sudo apt install -y eza zoxide 2>/dev/null || true
fi

# --- 2) Ensure Oh-My-Zsh installed ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "[*] Installing Oh-My-Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "[*] Oh-My-Zsh already present."
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# --- 3) Powerlevel10k theme ---
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "[*] Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "[*] Powerlevel10k already present."
fi

# --- 4) Plugins ---
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

# --- 5) Link configs ---
echo "[*] Linking configs into home directory..."
ln -sf "$REPO_DIR/zsh/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
# --- 6) Debian naming compatibility (bat/fd) ---
# Create lightweight shims in ~/.local/bin so commands are uniform across machines.
mkdir -p "$HOME/.local/bin"

if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi

if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

# --- 7) Ensure default shell is zsh (best-effort) ---
if command -v chsh >/dev/null 2>&1; then
  if [ "${SHELL:-}" != "/usr/bin/zsh" ] && [ -x /usr/bin/zsh ]; then
    echo "[*] Setting default shell to /usr/bin/zsh (may prompt)..."
    chsh -s /usr/bin/zsh || true
  fi
fi

echo "[*] Done. Start a new shell or run: exec zsh"
