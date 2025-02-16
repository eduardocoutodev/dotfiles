alias ls='ls --color'
alias noti='curl ntfy.sh/eduardo_notifications -d'
alias cat='bat'

alias python='python3'
alias pipi='pip install'

# Ohzsh
alias z='source $ZDOTDIR/.zshrc'
alias ze='vim $ZDOTDIR/.zshrc'
alias ae='vim $ZDOTDIR/conf.d/07-aliases.zsh'
alias a='cat $ZDOTDIR/conf.d/07-aliases.zsh'

# Git
alias gap='git add -p'
alias gpo='git push origin $(git symbolic-ref --short HEAD)'
alias gsr='git reset --soft HEAD~1'
alias ghr='git reset --hard HEAD~1'
alias gfp='git fetch --all --prune'
alias gca='git commit --amend'
alias gs='git stash -u'
alias gss='git stash save -u'
alias gsa='git stash apply'
alias gma='git merge --abort'
alias gpuo='git pull origin'

# Tmux
alias t='tmux source-file ~/.tmux.conf'
alias ta='tmux attach -t'
alias tns='tmux new -s'

# Shortcuts
alias c='cd ~/Code'
