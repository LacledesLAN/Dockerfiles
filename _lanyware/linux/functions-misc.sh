#!/bin/bash

function extname() #{{{1
{
    # <doc:extname> {{{
    #
    # Get the extension of the given filename.
    #
    # Usage: extname [-n LEVELS] FILENAME
    #
    # Usage examples:
    #     extname     foo.txt     #==> .txt
    #     extname -n2 foo.tar.gz  #==> .tar.gz
    #     extname     foo.tar.gz  #==> .tar.gz
    #     extname -n1 foo.tar.gz  #==> .gz
    #
    # </doc:extname> }}}

    local levels

    unset OPTIND
    while getopts ":n:" option; do
        case $option in
            n) levels=$OPTARG ;;
        esac
    done && shift $(($OPTIND - 1))

    local filename=${1##*/}

    [[ $filename == *.* ]] || return

    local fn=$filename
    local exts ext

    # Detect some common multi-extensions
    if [[ ! $levels ]]; then
        case $(lower <<<$filename) in
            *.tar.gz|*.tar.bz2) levels=2 ;;
        esac
    fi

    levels=${levels:-1}

    for (( i=0; i<$levels; i++ )); do
        ext=.${fn##*.}
        exts=$ext$exts
        fn=${fn%$ext}
        [[ $exts == $filename ]] && return
    done

    echo "$exts"
}


function abspath() #{{{1
{
    # <doc:abspath> {{{
    #
    # Gets the absolute path of the given path.
    # Will resolve paths that contain '.' and '..'.
    # Think readlink without the symlink resolution.
    #
    # Usage: abspath [PATH]
    #
    # </doc:abspath> }}}

    local path=${1:-$PWD}

    # Path looks like: ~user/...
    # Gods of bash, forgive me for using eval
    if [[ $path =~ ~[a-zA-Z] ]]; then
        if [[ ${path%%/*} =~ ^~[[:alpha:]_][[:alnum:]_]*$ ]]; then
            path=$(eval echo $path)
        fi
    fi

    # Path looks like: ~/...
    [[ $path == ~* ]] && path=${path/\~/$HOME}

    # Path is not absolute
    [[ $path != /* ]] && path=$PWD/$path

    path=$(squeeze "/" <<<"$path")

    local elms=()
    local elm
    local OIFS=$IFS; IFS="/"
    for elm in $path; do
        IFS=$OIFS
        [[ $elm == . ]] && continue
        if [[ $elm == .. ]]; then
            elms=("${elms[@]:0:$((${#elms[@]}-1))}")
        else
            elms=("${elms[@]}" "$elm")
        fi
    done
    IFS="/"
    echo "/${elms[*]}"
    IFS=$OIFS
}


function tempdir() #{{{1
{
    # <doc:tempdir> {{{
    #
    # Creates and keeps track of temp directories.
    #
    # Usage examples:
    #     tempdir    # $TEMPDIR is now a directory
    #
    # </doc:tempdir> }}}

    tempfile -d -t "$(basename "$0").XXXXXX"
    TEMPDIR=$TEMPFILE
}


function tolower()
{
    # <doc:tolower> {{{
    #
    # Lowercases all letters in a string
    #
    # Usage: tolower "String To Convert To Lowercase"
    #
    # Usage examples:
    #     tolower "String To Convert To Lowercase"     #==> "string to convert to lowercase"
    #
    # </doc:filename> }}}

    return $(echo "$1" | tr '[:upper:]' '[:lower:]')
}


function filename() #{{{1
{
    # <doc:filename> {{{
    #
    # Gets the filename of the given path.
    #
    # Usage: filename [-n LEVELS] FILENAME
    #
    # Usage examples:
    #     filename     /path/to/file.txt     #==> file
    #     filename -n2 /path/to/file.tar.gz  #==> file
    #     filename     /path/to/file.tar.gz  #==> file
    #     filename -n1 /path/to/file.tar.gz  #==> file.tar
    #
    # </doc:filename> }}}

    basename "$1" $(extname "$@")
}


function trim() #{{{1
{
    # <doc:trim> {{{
    #
    # Removes all leading/trailing whitespace
    #
    # Usage examples:
    #     echo "  foo  bar baz " | trim  #==> "foo  bar baz"
    #
    # </doc:trim> }}}

    ltrim "$1" | rtrim "$1"
}


function ltrim() #{{{1
{
    # <doc:ltrim> {{{
    #
    # Removes all leading whitespace (from the left).
    #
    # </doc:ltrim> }}}

    local char=${1:-[:space:]}
    sed "s%^[${char//%/\\%}]*%%"
}


function rtrim() #{{{1
{
    # <doc:rtrim> {{{
    #
    # Removes all trailing whitespace (from the right).
    #
    # </doc:rtrim> }}}

    local char=${1:-[:space:]}
    sed "s%[${char//%/\\%}]*$%%"
}

