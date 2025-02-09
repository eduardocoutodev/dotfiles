# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load all configurations from conf.d
for conf in ${ZDOTDIR:-$HOME/.config/zsh}/conf.d/*.zsh; do
  source $conf
done

if [[ -f "${ZDOTDIR}/local/${MACHINE_ENV}.zsh" ]]; then
    source "${ZDOTDIR}/local/${MACHINE_ENV}.zsh"
fi

# Load p10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
