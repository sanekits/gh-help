# gh-help.bashrc - shell init file for gh-help sourced from ~/.bashrc

gh-help-semaphore() {
    [[ 1 -eq  1 ]]
}

export GH_HELP_BASE="${GH_HELP_BASE:-$HOME/.local/bin/gh-help}"

[[ -f ~/.gh-helprc ]] \
    && source ~/.gh-helprc

if which gh &>/dev/null; then
    eval "$(command gh completion -s bash)"
fi

# TODO: move this to a config file:
export GH_MYORGS="$USER training-$USER org-$USER sanekits trn-bde-ci TdocProgressMetrics"

gh_enterprise() {
    # Enterprise-flavored 'gh' wrapper (we expect
    # that GH_ENTERPRISE_TOKEN_2 is defined in environment.  If not,
    # fall back to GH_ENTERPRISE_TOKEN)
    #
    # GH_HOST_ENTERPRISE belongs in ~/.gh-helprc
    local tok=${GH_ENTERPRISE_TOKEN_2}
    [[ -z "$tok" ]] && tok=${GH_ENTERPRISE_TOKEN}
    GH_ENTERPRISE_TOKEN=${tok} GH_TOKEN=${tok} GH_HOST=${GH_HOST_ENTERPRISE} command gh "$@"
}

gh_pub() {
    # (We expect that GH_TOKEN_2 is defined in environment, fallback
    # to GH_TOKEN if not)
    local tok=${GH_TOKEN_2}
    [[ -z "$tok" ]] && tok=${GH_TOKEN}
    GH_TOKEN=${tok} GH_ENTERPRISE_TOKEN= GH_HOST=github.com command gh "$@"
}

alias ghe=gh_enterprise
alias gh=gh_pub
complete -o default -F __start_gh ghe &>/dev/null

alias ghil='gh issue list'
alias ghic='gh issue create'
alias ghpl='gh issue list'
alias ghpr='gh pr create'
alias gh_gist='gh-gist.sh'
alias gh_gist_create='gh-gist.sh create'
alias ghe_gist_create='gh-gist.sh -e create'
alias gh_gist_list='gh-gist.sh list'
alias ghe_gist_list='gh-gist.sh -e list'
alias gh_gist_edit='gh-gist.sh edit'
alias ghe_gist_edit='gh-gist.sh -e edit'
alias ghe_repo_find='gh-repo-find.sh -e'
true
