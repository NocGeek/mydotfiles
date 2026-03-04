# ~/.zshrc (managed by dotfiles)

### ----------------------------
### Fast prompt (Powerlevel10k)
### ----------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

### ----------------------------
### PATH / Basics
### ----------------------------
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--R -F -X -K}"

### ----------------------------
### History (per-machine)
### ----------------------------
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY

### ----------------------------
### Oh-My-Zsh
### ----------------------------
export ZSH="$HOME/.oh-my-zsh"
plugins=(git)
export ZSH_THEME="powerlevel10k/powerlevel10k"
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

### ----------------------------
### Tool naming compatibility (Debian)
### ----------------------------
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  alias bat="batcat"
fi
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
  alias fd="fdfind"
fi

### ----------------------------
### Modern CLI aliases (only if tool exists)
### ----------------------------

# eza (modern ls)
# Icons require a Nerd Font in YOUR LOCAL terminal.
# Enable icons by setting: export EZA_ICONS=1
if command -v eza >/dev/null 2>&1; then
  EZA_ICON_FLAG=""
  [[ "${EZA_ICONS:-0}" = "1" ]] && EZA_ICON_FLAG="--icons"

  alias ls="eza ${EZA_ICON_FLAG}"
  alias ll="eza -lh ${EZA_ICON_FLAG}"
  alias la="eza -lha ${EZA_ICON_FLAG}"
  alias lt="eza --tree --level=2 ${EZA_ICON_FLAG}"
fi

# bat (modern cat)
if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style=plain'
fi

# rg (modern grep)
if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
fi

# Safer defaults
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'

# Convenience
alias dfh='df -h'
alias duh='du -h --max-depth=1'
alias path='echo $PATH | tr ":" "\n"'

### ----------------------------
### zoxide (smart cd)
### ----------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

### ----------------------------
### fzf (history + file search)
### ----------------------------
if command -v fzf >/dev/null 2>&1; then
  [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi
fi

### ----------------------------
### zsh-autosuggestions + syntax-highlighting
### ----------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [[ -r "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -r "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

### ----------------------------
### Powerlevel10k config
### ----------------------------
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
