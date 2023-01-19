# gh-help.bashrc - shell init file for gh-help sourced from ~/.bashrc

gh-help-semaphore() {
    [[ 1 -eq  1 ]]
}

GH_HELP_BASE="${GH_HELP_BASE:-$HOME/.local/bin/gh-help}"

[[ -f ~/.gh-helprc ]] \
    && source ~/.gh-helprc

if which gh &>/dev/null; then
    eval "$(command gh completion -s bash)"
    if [[ -n GH_HOST_ENTERPRISE ]]; then
        alias ghe="GH_HOST=${GH_HOST_ENTERPRISE} command gh"
        complete -F _complete_alias ghe
    fi
fi

alias ghil='gh issue list'
alias ghic='gh issue create'
alias ghpl='gh issue list'
alias ghpr='gh pr create'

true
