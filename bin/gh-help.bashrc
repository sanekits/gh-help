# gh-help.bashrc - shell init file for gh-help sourced from ~/.bashrc

gh-help-semaphore() {
    [[ 1 -eq  1 ]]
}

GH_HELP_BASE="${GH_HELP_BASE:-$HOME/.local/bin/gh-help}"

[[ -f ~/.gh-helprc ]] \
    && source ~/.gh-helprc

if which gh &>/dev/null; then
    eval "$(command gh completion -s bash)"
fi

gh_enterprise() {
    # Enterprise-flavored 'gh' wrapper (we expect
    # that GH_ENTERPRISE_TOKEN is defined in environment)
    GH_TOKEN= GH_HOST=${GH_HOST_ENTERPRISE} command gh "$@"
}

gh_pub() {
    # (We expect that GH_TOKEN is defined in environment)
    GH_ENTERPRISE_TOKEN= GH_HOST=github.com command gh "$@"
}

alias ghe=gh_enterprise
alias gh=gh_pub
complete -F _complete_alias ghe &>/dev/null

alias ghil='gh issue list'
alias ghic='gh issue create'
alias ghpl='gh issue list'
alias ghpr='gh pr create'

true
