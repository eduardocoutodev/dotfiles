export PATH=/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/sbin:/Users/eduardo.couto/homebrew/bin

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check if running on Ubuntu
if [[ "$(uname -s)" == "Linux" && -f /etc/os-release ]]; then
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Set the directory for zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source / Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found

# Load completions
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Share Terminal History
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
# Ignore case sensitive autocompletion, allowing cd /Etc or cd /etc to be the same
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Source Aliases file 
source ~/.zsh_aliases

# source Private Aliases
if [[ -f "~/.private_zsh_aliases" ]] then
  # If you're using macOS, you'll want this enabled
  source ~/.private_zsh_aliases
fi

install_jdk_certificates() {
  echo "Starting to install jdk certificates"
  GITHUB_CERT_PATH=/tmp/maven-github.crt
  ARTIFACTORY_PEM_PATH=/tmp/maven-artifactory.pem
  [[ ! -f $GITHUB_CERT_PATH ]] && openssl x509 -in <(openssl s_client -connect maven.pkg.github.com:443 -prexit 2>/dev/null) -out $GITHUB_CERT_PATH
  [[ ! -f $ARTIFACTORY_PEM_PATH ]] && (echo quit | openssl s_client -showcerts -servername artifactory-prd.prd.betfair -connect artifactory-prd.prd.betfair:443 > $ARTIFACTORY_PEM_PATH)
  sudo keytool -delete -alias dstools -keystore ~/.m2/artifactory-truststore.jks -storepass trustme
  sudo keytool -import -noprompt -trustcacerts -alias dstools -file $ARTIFACTORY_PEM_PATH -keystore ~/.m2/artifactory-truststore.jks -storepass trustme
  sudo keytool -delete -alias maven.pkg.github.com -file $ARTIFACTORY_PEM_PATH -keystore ~/.m2/artifactory-truststore.jks -storepass trustme
  sudo keytool -import -noprompt -trustcacerts -file $GITHUB_CERT_PATH -alias maven.pkg.github.com -keystore ~/.m2/artifactory-truststore.jks -storepass trustme
  JAVA_VERSION=`java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1`
  if (( $JAVA_VERSION >= 9 )); then
    CACERTS="-cacerts"
    sudo keytool -importkeystore -noprompt -srckeystore ~/.m2/artifactory-truststore.jks $CACERTS -srcstorepass trustme -deststorepass changeit
  else
    # Check where cacerts are located
    # differs depending or jdk or jre installed
    if [ -d "$(sdk home java)/jre" ]; then
    CACERTS="$(sdk home java)/jre"
    else
    CACERTS="$(sdk home java)"
    fi
    sudo keytool -importkeystore -noprompt -srckeystore ~/.m2/artifactory-truststore.jks -destkeystore $CACERTS/lib/security/cacerts -srcstorepass trustme -deststorepass changeit
  fi
}

#install_jdk_certificates

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

#export JAVA_HOME=/Users/eduardocouto/.sdkman/candidates/java/current

# Created by `pipx` on 2024-08-21 19:07:48
export PATH="$PATH:/Users/eduardocouto/.local/bin"

# Export Homebrew to path
export PATH="/opt/homebrew/bin:$PATH"

## Add Global Scripts

chmod +x ~/scripts/*

export PATH="$HOME/scripts:$PATH"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Load NVM

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -d /Users/eduardo.couto/.git-flutter/bin ] && export PATH="/Users/eduardo.couto/.git-flutter/bin:$PATH"

# Load go binary
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$(go env GOPATH)/bin"

# Add podman to path
#export PATH="$PATH:/opt/podman/bin"

export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
