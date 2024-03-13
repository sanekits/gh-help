#!/bin/bash
# ghe.sh: run gh_enterprise() (from gh-help.bashrc) in a shell script.

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

[[ -z ${sourceMe} ]] && {
    source ${scriptDir}/gh-help.bashrc
    set -ue
    gh_enterprise "$@"
}
command true

