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
PS4='\033[0;33m+(${BASH_SOURCE}:${LINENO}):\033[0m ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
#set -x

source ${scriptDir}/shellkit/setup-base.sh

die() {
    builtin echo "ERROR(setup.sh): $*" >&2
    builtin exit 1
}

make_gh_helprc() {
    cat <<-EOF
# gh-helprc
#   See https://github.com/sanekits/gh-help

# TODO: set this to point to the hostname for your Github Enterprise server.
# Then the "ghe" alias will be enabled during shell init.

# export GH_HOST_ENTERPRISE=myenterprise.local

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
    type -P gh || {
        echo "WARNING: no 'gh' command found on the PATH.  If it's not installed, try $PWD/gh-help/gh-install.sh"
    }
    # FINALIZE: perms on ~/.local/bin/<Kitname>.  We want others/group to be
    # able to traverse dirs and exec scripts, so that a source installation can
    # be replicated to a dest from the same file system (e.g. docker containers,
    # nfs-mounted home nets, etc)
    command chmod og+rX ${HOME}/.local/bin/${Kitname} -R
    command chmod og+rX ${HOME}/.local ${HOME}/.local/bin
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    builtin exit
}
command true
