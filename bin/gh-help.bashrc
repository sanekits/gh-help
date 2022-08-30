# gh-help.bashrc - shell init file for gh-help sourced from ~/.bashrc

gh-help-semaphore() {
    [[ 1 -eq  1 ]]
}

GH_HELP_BASE="${GH_HELP_BASE:-$HOME/.local/bin/gh-help}"

gh() {
    #help: wrap the Github gh cli
    ${GH_HELP_BASE}/gh-help.sh "$@"
}
