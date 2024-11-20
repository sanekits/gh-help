#!/bin/bash
# gh-repo-find.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
#PS4='\033[0;33m+$?( $( realpath ${BASH_SOURCE} 2>/dev/null || echo unk-source ):${LINENO}  ):\033[0m ${#FUNCNAME[@]}:+${FUNCNAME[0]}()✨ '

set -ue

ORG_LIST="${GH_MYORGS:-${USER}}"
source "${scriptDir}/gh-help.bashrc"
gh_command=gh_pub  # -e|--enterprise option will set this to gh_enterprise()

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

gh_help_find() {
    builtin echo "Usage: $(basename ${scriptName}) [OPTIONS] [--] GREP_ARGS"
    builtin echo "  -o, --org ORGNAME  Add org to search list (multiples allowed)"
    builtin echo "  -e, --enterprise   Search in BBGitHub"
    builtin echo "  -h, --help         Display this help message"
    builtin echo "  --                 End of non-grep options"
    builtin echo "  GREP_ARGS          Args passed to grep"
    builtin echo "  ORGNAME            Organization name, defaults to the value"
    builtin echo "                     of the GH_MYORGS environment variable."
    builtin echo "  GH_MYORGS=${GH_MYORGS}"
    builtin echo
    builtin echo "  Example: $(basename ${scriptName}) -o myorg -- -E '^.*foobar[0-9]+.*$'"
}

set +u
[[ -z ${sourceMe} ]] && {
    while [[ -n $1 ]]; do
        case $1 in
            -o|--org) shift; ORG_LIST="$ORG_LIST $1" ;;
            -e|--enterprise) shift; gh_command=gh_enterprise; continue;;
            -h|--help) gh_help_find; builtin exit;;
            --) shift; break;;
           *) break;;
        esac
        shift
    done
    [[ $# -eq 0 ]] && { gh_help_find; exit 1; }
    set -u
    set -o pipefail
    for org in $ORG_LIST; do
        ${gh_command} repo list $org --limit 1000 | grep -E "$@" || :
    done
    builtin exit
}
command true
