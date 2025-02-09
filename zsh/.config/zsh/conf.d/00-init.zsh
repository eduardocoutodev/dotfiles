source "${ZDOTDIR}/conf.d/07-aliases.zsh"

# Load machine-specific aliases
if [[ -f "${ZDOTDIR}/local/${MACHINE_ENV}/aliases.zsh" ]]; then
    source "${ZDOTDIR}/local/${MACHINE_ENV}/aliases.zsh"
fi