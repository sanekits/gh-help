#!/bin/bash
# setup.sh for gh-help
#  This script is run from a temp dir after the self-install code has
# extracted the install files.   The default behavior is provided
# by the main_base() call, but after that you can add your own logic
# and installation steps.

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

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}
scriptName="$(canonpath  $0)"
scriptDir=$(command dirname -- "${scriptName}")

source ${scriptDir}/shellkit/setup-base.sh

die() {
    builtin echo "ERROR(setup.sh): $*" >&2
    builtin exit 1
}

make_gh_helprc() {
    cat <<-EOF
# gh-helprc
#   See https://github.com/sanekits/gh-help

# TODO: set this to point to the hostname for your Github Enterprise server
#  Then you can pass "-e" as the first argument to "gh-help.sh" so that the
#  gh command uses the enterprise host instead of github.com for operations.
export GH_HOST_ENTERPRISE=myenterprise.local

# TODO: uncomment this alias if you want to use 'ghe' as a shortcut with
# Github Enterprise:
# alias ghe='gh-help.sh -e'

EOF
}

main() {
    Script=${scriptName} main_base "$@"
    builtin cd ${HOME}/.local/bin || die 208

    [[ -f ~/.gh-helprc ]] && {
        make_gh_helprc > ~/.gh-helprc.proposed
        command diff ~/.gh-helprc.proposed ~/.gh-helprc && {
            command rm ~/.gh-helprc.proposed
        } || {
            (
                builtin echo "WARNING: contents of ~/.gh-helprc does not match ~/.gh-helprc.proposed."
                builtin echo "Manually diff the files and merge changes if needed."
            ) >&2
        }
    } || {
        make_gh_helprc > ~/.gh-helprc
        builtin echo "~/.gh-helprc has been created: review and customize this file."
    }
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
