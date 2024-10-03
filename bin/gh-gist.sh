#!/bin/bash
# gh-gist.sh

scriptName="$(readlink -f "$0")"
scriptDir=$(command dirname -- "${scriptName}")
PS4='\033[0;33m+$?( $( realpath ${BASH_SOURCE} 2>/dev/null || echo unk-source ):${LINENO}  ):\033[0m ${#FUNCNAME[@]}:+${FUNCNAME[0]}()✨ '

source ${scriptDir}/gh-help.bashrc

gh_command=gh_pub  # -e|--enterprise option will set this to gh_enterprise()
FIELD_NDX=()


die() {
    builtin echo "ERROR($(basename ${scriptName})): $*" >&2
    builtin exit 1
}

make_generic_description() {
    echo "Created by ${USER} with $(basename ${scriptName}) on $(date -Iminutes)"
}

invoke_vscode() {
    if which code-server &>/dev/null; then
        code-server "$@"
        return
    elif which code &>/dev/null; then
        if [[ ${HOME} == /root ]]; then
            code --user-data-dir=/root/.config/code-server --no-sandbox "$@"
            return
        else
            code "$@"
            return
        fi
    fi
    false
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

do_list_raw() {
    local limit="$1"
    if [[ ${#FIELD_NDX[@]} -gt 0 ]]; then
        # Join the array elements with commas to form the field list for cut
        field_list=$(IFS=,; echo "${FIELD_NDX[*]}")
        ${gh_command} gist list --limit "$limit" | cut -f"${field_list}" -d $'\t'
    else
        ${gh_command} gist list --limit "$limit"
    fi
}

do_list() {
    # List gists.  Arguments are used to filter the list by substring
    # matching against the id and description
    local limit=20 filter=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -l) shift; limit=$1 ;;
            -f) shift; FIELD_NDX+=($1) ;;
            -*) die "Unknown list option: $1";;
            *) filter+=($1);;
        esac
        shift
    done

    if [[ ${#filter[@]} -gt 0 ]]; then
        # Expand filter elements into a single string with '.*' between them for grep
        filter_string=$(printf '.*%s' "${filter[@]}")
        do_list_raw "$limit" | grep -E "${filter_string:2}.*" || :
    else
        do_list_raw "$limit"
    fi
    FIELD_NDX=()
}

get_title_for_hash() {
    # Given hashed dirname(s) in ~/gist-edit, print the basename of the title symlink which
    # points to it
    local hash
    for hash in "$@"; do
    (
        set -ue
        builtin cd ${HOME}/gist-edit
        links=(  $( find . -maxdepth 1 -type l | cut -c 3- )  )
        for link in ${links[@]}; do
            if [[ $( readlink ${link} ) == *${hash} ]]; then
                echo ${link}
                exit
            fi
        done
        echo "${hash}"
    )
    done
}

do_edit() {
    # Edit one or more gists.  Each is cloned to ~/gist-edit/<id> first, if not
    # already there.  Existing gists are refreshed with 'git pull'
    # If only one gist is selected, user is offered to edit it with editor.

    local items=()
    local desc=()
    while read id text; do
        items+=(${id})
        desc+=("${id} ${text}")
    done < <(do_list -f 1 -f 2 "$@")

    [[ ${#items[@]} -eq 0 ]] && die "No gists matched."
    [[ ${#items[@]} -gt 10 ]] && {
        do_list "$@"
        die "Too many matches.  I'm not in the mood to clone all that!"
    }
    [[ -d ~/gist-edit ]] || mkdir -p ~/gist-edit
    for item in ${items[@]}; do
        gist_id=${item}
        gist_dir=${HOME}/gist-edit/${gist_id}
        if [[ ! -d ${gist_dir} ]]; then
            (
                set -ue
                cd ~/gist-edit
                ${gh_command} gist clone ${gist_id}
                # Turn the description into a symlink name:
                symlink_title=$( printf "%s\n" "${desc[@]}" | awk "/^${gist_id}/ { \$1=\"\"; sub(/^ /, \"\"); print }" | tr '/ \t' '-' )
                # limit the title to 45 chars:
                symlink_title=${symlink_title:0:45}
                ln -sf ${gist_id} ${symlink_title}
                cd ${symlink_title}
                echo "$PWD 1" >> ~/.tox-index
            )
        else
            (cd ${gist_dir} && git pull)
        fi
    done
    if [[ ${#items[@]} -eq 1 && -t 1 ]]; then
        gist_title="$(get_title_for_hash ${gist_id})"
        echo "Load ~/gist-edit/${gist_title} into editor? [y/N]"
        read -n1 answer
        [[ ${answer} == [yY] ]] && {
            invoke_vscode -n ~/gist-edit/${gist_title} && exit
            [[ -n "${EDITOR}" ]] || die "No editor found.  Set EDITOR environment variable."
            ${EDITOR} ${gist_title}
        }
    else
        for item in ${items[@]}; do
            get_gist_title "$item"
        done
    fi

}

gh_gist_help() {
    echo "Usage: $(basename ${scriptName}) [mode] <OPTIONS> <FILE>"
    echo "Gist management helper"
    echo "Options:"
    echo "  -e, --enterprise               Use GitHub Enterprise."
    echo "  -h, --help                     Show this help message."
    echo ""
    echo "Modes:"
    echo
    echo "  create                         Create a new gist."
    echo "    Create a new gist from FILE or stdin."
    echo "    -d, --description DESCRIPTION  Set the gist description."
    echo "    -f, --filename FILENAME        Set the gist filename."
    echo "    -v, --private                  Make the gist private."
    echo
    echo "  list [filter..args]             List gists."
    echo "    List gists, optionally filtering by substring matching."
    echo "        (Multiple filter args are combined with '.*' for regex)"
    echo "    -l [nn] Limit the number of gists listed."
    echo
    echo "  edit [filter..args]              Edit existing gists."
    echo "    Edit one or more existing gist by matching filters"
    echo
}

[[ -z ${sourceMe} ]] && {
    while [[ $# -gt 0 ]]; do
        case $1 in
            create) shift; do_create "$@"; exit;;
            list) shift; do_list "$@"; exit;;
            edit) shift; do_edit "$@"; exit;;
            -e|--enterprise) shift; gh_command=gh_enterprise; continue;;
            -h|--help) shift; gh_gist_help "$@"; exit;;
            *) gh_gist_help; die "Unknown option(s): $@" ;;
        esac
        shift
    done
    gh_gist_help
    die "No mode specified. Try 'create' or -h for help."
}
command true
+
