#!/bin/bash
# gh-cli-bootstrap.sh
#
#shellcheck disable=2154
PS4='\033[0;33m$( _0=$?;set +e;exec 2>/dev/null;realpath -- "${BASH_SOURCE[0]:-?}:${LINENO} \033[0;35m^$_0\033[32m ${FUNCNAME[0]:-?}()=>" )\033[;0m '

scriptName="${scriptName:-"$(command readlink -f -- "$0")"}"
# (if needed) scriptDir="$(command dirname -- "${scriptName}")"
[[ -n "${DEBUGSH}" ]] && set -x

Sudo=


{
    die() {
        builtin echo "ERROR($(basename "${scriptName}")): $*" >&2
        builtin exit 1
    }
    set_sudo_mode() {
        if [[ $(id -u) == 0 ]]; then
            # we're already root
            return 0
        fi
        if command which sudo &>/dev/null; then
            # sudo exists, but we don't know if we have that power and should use it?
            read -rp "sudo exists.  Do you want to use it to install gh-cli? If not, you'll get a user install in ~/.local/bin [n/Y]:"
            [[ $REPLY =~ [yY] ]] && { Sudo='sudo '; return 0; }
        fi
    }
}

sudo_install() {
    #  todo
    :
}

user_install() {
    set -ue
    local VER=2.72.0
    local ARCH=amd64
    local Tarname="gh_${VER}_linux_${ARCH}"

    mkdir -p ~/.local/bin ; cd ~/.local/bin || die "30"
    local url="https://github.com/cli/cli/releases/download/v${VER}/${Tarname}.tar.gz"
    if ! curl -L "$url" -o "${Tarname}.tar.gz"; then
        die "Failed downloading $url"
    fi

    # Unpack and move just the executable to ~/.local/bin
    tar -xzf ${Tarname}.tar.gz || die 31
    mv ${Tarname}/bin/gh ./ || die 32

    # bash completion script:
    mkdir -p ~/.bash_completion.d
    ./gh completion -s bash > ~/.bash_completion.d/gh || die 33

    # Clean up 
    rm -rf ${Tarname}*
}

main() {
    set -ue
    set -x
    # if set_sudo_mode; then
    #     sudo_install "$@"
    # else
         user_install "$@"
    # fi
}

if [[ -z "${sourceMe:-}" ]]; then
    main "$@"
    builtin exit
fi
command true

