# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# iTerm2 Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Make scripts executable
if [[ -f "~/scripts/" ]]; then
    chmod +x ~/scripts/* 2>/dev/null || true
fi

