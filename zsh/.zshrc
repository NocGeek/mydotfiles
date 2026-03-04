# =========================
#  Powerlevel10k (instant prompt)
# =========================
# Must be at the very top. Anything that can prompt for input goes ABOVE this.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========================
#  Basics
# =========================
export EDITOR=vim
setopt prompt_subst

# PATH (keep this early so everything later can see it)
export PATH="$HOME/.local/bin:$PATH"

# =========================
#  History (large, shared, deduped, timestamped)
# =========================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=500000
SAVEHIST=500000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# =========================
#  # Comments behavior (pick ONE)
# =========================
# Option A (recommended for most people):
#   - You can type:   # comment
#   - But if you paste a URL/command containing '#', everything after # is ignored unless quoted/escaped.
# setopt interactive_comments

# Option B (recommended if you frequently paste URLs/fragments with #):
#   - Pasted commands with # won't get truncated
#   - But typing:  # comment   will try to run a command named '#'
unsetopt interactive_comments

# Tip if you use Option A and paste URLs with #:
#   quote them:  curl "https://example.com/page#section"
#   or escape:   https://example.com/page\#section

# =========================
#  Completion
# =========================
autoload -Uz compinit

# Use a per-host compdump to avoid weirdness when sharing home dirs
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump-${HOST}"
compinit -d "$ZSH_COMPDUMP"

setopt AUTO_MENU
setopt MENU_COMPLETE
setopt CORRECT

zstyle ':completion:*' menu select
zstyle ':completion:*' verbose true
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z}={A-Z}' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

# Colors for completion lists (if LS_COLORS exists)
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"
fi

# =========================
#  Keybinds + paste fixes
# =========================
bindkey -e  # emacs bindings

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# Home/End (common terminals)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Arrow-key history (use normal up/down by default)
bindkey '^[OA' up-history
bindkey '^[OB' down-history
bindkey '^[[A' up-history
bindkey '^[[B' down-history

# =========================
#  Colorized ls/grep + common aliases
# =========================
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'

# =========================
#  Plugins (standalone, no Oh-My-Zsh)
# =========================
# Autosuggestions (loads fast, should be before syntax-highlighting)
if [[ -r ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi

# Syntax highlighting (must be after autosuggestions)
if [[ -r ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Optional (highly recommended): history substring search
# Lets Up/Down match what you've typed so far (often feels like "better autocomplete")
if [[ -r ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
  source ~/.zsh-plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
fi

# =========================
#  Powerlevel10k theme
# =========================
# Theme first...
if [[ -r ~/.powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source ~/.powerlevel10k/powerlevel10k.zsh-theme
fi

# ...then your p10k config (prompt settings)
if [[ -r ~/.p10k.zsh ]]; then
  source ~/.p10k.zsh
fi
