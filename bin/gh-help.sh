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
    if [[ $1 == "-e" ]]; then
        shift
        source ~/.gh-helprc
        [[ -n $GH_HOST_ENTERPRISE ]] || die "-e option specified, but GH_HOST_ENTERPRISE is not defined in ~/.gh-helprc.  So I don't know where your Github Enterprise server is located and can't help."
        export GH_HOST=$GH_HOST_ENTERPRISE
    fi

    command gh "$@"
}

[[ -z ${sourceMe} ]] && {
    main "$@"
    exit
}
true
