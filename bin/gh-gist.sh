#!/bin/bash
# gh-gist.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")

source ${scriptDir}/gh-help.bashrc

gh_command=gh_pub  # -e|--enterprise option will set this to gh_enterprise()


die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

make_generic_description() {
    echo "Created by ${USER} with $(basename ${scriptName}) on $(date -Iminutes)"
}


do_create() {
    # Create a new gist.  By default:
    #   - we read from stdin and name the file README.md.
    #   - we make the gist public.  (-v|--private will make it private)
    #   - we provide a generic description.
    local description="$(make_generic_description)" gistFile=- public=1 filename=README.md
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--description) shift; description="$1"; shift; continue;;
            -v|--private) public=0; shift; continue;;
            -f|--filename) shift; filename="$1"; shift; continue;;
            *) gistFile="$1"; shift; continue;;
        esac
        shift
    done
    [[ -z ${gistFile} ]] && die "No gist file specified."
    ${gh_command} gist create ${public:+-p} --filename "${filename}" ${description:+-d} "${description}" "${gistFile}"
}

gh_gist_help() {
    echo "Usage: $(basename ${scriptName}) [mode] <OPTIONS> <FILE>"
    echo "Create a new gist from FILE or stdin."
    echo "Options:"
    echo "  -e, --enterprise               Use GitHub Enterprise."
    echo "  -h, --help                     Show this help message."
    echo ""
    echo "Modes:"
    echo "  create                         Create a new gist."
    echo "    -d, --description DESCRIPTION  Set the gist description."
    echo "    -f, --filename FILENAME        Set the gist filename."
    echo "    -v, --private                  Make the gist private."
}

[[ -z ${sourceMe} ]] && {
    while [[ $# -gt 0 ]]; do
        case $1 in
            create) shift; do_create "$@"; exit;;
            -e|--enterprise) shift; gh_command=gh_enterprise; continue;;
            -h|--help) shift; gh_gist_help "$@"; exit;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
    die "No mode specified. Try 'create' or -h for help."
}
command true
