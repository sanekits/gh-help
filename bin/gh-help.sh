#!/bin/bash
# gh-help.sh
#  This wrapper forwards args to the Github 'gh' cli.  Except:
#   - When first arg is "-e", which will set the GH_HOST environment
#     variable to the value of GH_HOST_ENTERPRISE.
#     This behavior solves a shortcoming of the current 'gh' command line,
#     which does not always provide explicit specification of the host.

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

stub() {
   builtin echo "  <<< STUB[$*] >>> " >&2
}
main() {
    builtin echo "Hello gh-help, shellkit edition: args:[$*]"
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    exit
}
true
