#!/bin/bash
# gh-help.sh

canonpath() {
    builtin type -t realpath.sh &>/dev/null && {
        realpath.sh -f "$@"
        return
    }
    builtin type -t readlink &>/dev/null && {
        command readlink -f "$@"
        return
    }
    # Fallback: Ok for rough work only, does not handle some corner cases:
    ( builtin cd -L -- "$(command dirname -- $0)"; builtin echo "$(command pwd -P)/$(command basename -- $0)" )
}

scriptName="$(canonpath "$0")"
scriptDir=$(command dirname -- "${scriptName}")


die() {
    builtin echo "ERROR($(command basename -- ${scriptName})): $*" >&2
    builtin exit 1
}

main() {
    which gh || {
        gh_setup_advise
        exit
    }
    echo "Run 'gh help' or 'ghe help' (for the Enterprise edition)"
    echo
    echo "To setup authentication, run 'gh auth login' or 'ghe auth login'"
    echo
    echo "Tip: If bash autocompletion isn't working at the shell prompt, verify that the"
    echo "bash-completion DPKG package is installed (e.g. 'apt-get install bash-completion')"
    echo "and the 'bashics' shellkit (e.g. 'shpm install bashics')"
    echo
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    exit
}
true
