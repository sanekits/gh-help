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
cat <<-XEOF
Run 'gh help' or 'ghe help' (for the Enterprise edition)

- To setup authentication, run 'gh auth login' or 'ghe auth login'

- $EDITOR ~/.gh-helprc # User-editable options for this kit

- If bash autocompletion isn't working at the shell prompt, verify that the
bash-completion DPKG package is installed (e.g. 'apt-get install bash-completion')
and the 'bashics' shellkit (e.g. 'shpm install bashics')

Commands:
ghil  # gh issue list  << List issues for this repo
ghic  # gh issue create  << Create issue in this repo
ghpl  # gh pr list     << List PRs for this repo
ghpr  # gh pr create   << Create PR for this repo
ghe.sh # << Run gh in enterprise mode (e.g. scripts)
XEOF
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    exit
}
true
