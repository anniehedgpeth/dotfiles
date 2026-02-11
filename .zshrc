# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download zinit if it is not there yet
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
# source and load zinit
source "${ZINIT_HOME}/zinit.zsh"

# cargo
export PATH="$HOME/.cargo/bin:$PATH"

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_BUNDLE_FILE="~/.config/homebrew/Brewfile"
export HOMEBREW_NO_ENV_HINTS=true

# plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Load completions
autoload -U compinit && compinit

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab-complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias c='clear'

# aliases
# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls -lah'
alias ~='cd ~'

# git
alias gs='git status'
alias gp='git pull'
alias gcom='git checkout main'

# configuration
alias update='./update.sh' 

# personal 
alias app='cd ~/source/github/hedge-ops/people/'
alias dev='app && code'
alias dotfiles='cd ~/dotfiles'
alias j='just'
alias lg='lazygit'

# secrets, see template for details
[ -f "$HOME/.env" ] && source "$HOME/.env"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"
# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# Docker (via Colima)
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock" 

# Also look at bun (for bunx), then .local (for claude)
export PATH="$HOME/.bun/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# Aqua gets priority
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
