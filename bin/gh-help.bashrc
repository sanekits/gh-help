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

true

# gh() {
#     #help: wrap the Github gh cli
#     local gh_install_url="https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
#     type -P gh &>/dev/null || return $(die "no 'gh' command installed on the PATH, visit $gh_install_url")
#     [[ -x ${GH_HELP_BASE}/gh-help.sh ]] || return $(die "Can't find ${GH_HELP_BASE}/gh-help.sh")
#     ${GH_HELP_BASE}/gh-help.sh "$@"
# }
