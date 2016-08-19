#!/bin/bash

# Downloads a repo from GitHub; caches it; and places the content in a specified directory
# $1 The GitHub repo name include the GitHub group (group/name)
# $2 The destination directory
# OPTIONAL FLAGS
#   --skip-cache            Skip storing the downloaded repo into LANYWARE's cache'
#   --skip-destination      Skip copying the repo into the output folder; usefull for preloading any local lan-cache
#   --skip-remote           Skip updating from the remote source; used in LANYWARE's "development" mode
function import_github_repo() {

    local SKIP_CACHE=false;
    local SKIP_DESTINATION=false;
    local SKIP_REMOTE=false;
    local REPO_ALREADY_PULLED=false;

    # Verify that `git` is installed
    {
        git version;
    } &> /dev/null;

    if [ $? -ne 0 ]; then
        echo "ERROR: git command must be installed!" >&2;
        exit 3;
    fi

    # GITHUB_REPO_NAME (Parameter $1)
    if [ -z "$1" ]; then
        echo "-Parameter #1 (repository name) is required; cannot be zero length1";
        exit 1;
    elif [[ "$1" == *"://"* ]]; then
        echo "-Parameter #1 (repository name) cannot contain protocol information!";
        exit 1;
    else
        local GITHUB_REPO_NAME="$1";
    fi;

    # PATH_DESTINATION (Parameter $2)
    if [ -z "$1" ]; then
        echo "-Parameter #2 (destination path) is required; cannot be zero length1";
        exit 1;
    else
        local PATH_DESTINATION;
        PATH_DESTINATION=$(realpath "$2");
        mkdir "$PATH_DESTINATION" --parents;

        if [ $? -ne 0 ]; then
            echo "Could not prepare destination directory" >&2;
            exit 2;
        fi
    fi;

    # parse additional options
    for arg in "$@"; do
        case $arg in
            "--skip-cache")             # 
                    SKIP_CACHE=true;
                ;;
            "--skip-destination")       # 
                    SKIP_DESTINATION=true;
                ;;
            "--skip-remote")            # 
                    SKIP_REMOTE=true;
                ;;
        esac
    done;

    if [[ "$SKIP_CACHE" = true ]] && [[ "$SKIP_REMOTE" = true ]]; then
        echo "ERROR: cannot simultaneously --skip-cache and --skip-remote" >&2;
        exit 2;
    fi;

    echo -e "Importing GITHub Repo";

    # PATH_CACHED_REPO 
    local PATH_CACHED_REPO="";

    if [[ "$SKIP_CACHE" = true ]]; then
        PATH_CACHED_REPO=$(mktemp -d);
    else
        PATH_CACHED_REPO=$(echo "$GITHUB_REPO_NAME" | sed -e 's/\//_/g');       # PATH_CACHED_REPO with "/" replaced with "_"
        PATH_CACHED_REPO="$CACHE_DIRECTORY/github.com/$PATH_CACHED_REPO";       # Append cache directory

        array_contains LANYWARE_GITHUB_IMPORT_HISTORY "$GITHUB_REPO_NAME" && REPO_ALREADY_PULLED=true;
    fi;

    mkdir "$PATH_CACHED_REPO" --parents;

    if [[ "$SKIP_REMOTE" = false ]]; then
        echo -e "\t[Remote Source] $GITHUB_REPO_NAME";

        if [ $REPO_ALREADY_PULLED = true ]; then
            echo -e "\tRepo already up to date";
        elif [ $REPO_ALREADY_PULLED = false ]; then
            {
                if [[ "$(ls -A $PATH_CACHED_REPO/)" ]]; then
                    # cache directory is empty; preform a git clone
                    git -C "$PATH_CACHED_REPO/" pull;
                else
                    # if cache directory not empty; preform a git pull
                    git clone "git://github.com/$GITHUB_REPO_NAME" $PATH_CACHED_REPO;
                fi;
            } &> /dev/null;

            if [ $? -ne 0 ]; then
                echo -e "\tERROR: Could not clone/pull repo. Check that provided repo is valid." >&2
                exit 2;
            else
                echo -e "\t                Repo succesfully updated from remote source GitHub.com";
            fi;

            if [[ "$SKIP_CACHE" = false ]]; then
                if [[ ${#LANYWARE_GITHUB_IMPORT_HISTORY[@]} ]]; then
                    LANYWARE_GITHUB_IMPORT_HISTORY+=("$GITHUB_REPO_NAME");
                else
                    LANYWARE_GITHUB_IMPORT_HISTORY[0]="$GITHUB_REPO_NAME";
                fi;
            fi;
        fi;
    else
        echo -e "\t[Remote Source] (skipped)";
    fi;

    echo -e "\t[Cache] $PATH_CACHED_REPO"; 

    # Copy from cache to the destination directory; excluding the ".git" directory
    if [[ "$SKIP_DESTINATION" = true ]]; then
        echo -e "\t[Destination] (skipped)";
    else
        rsync -ahr --exclude=.git --exclude=README.md "$PATH_CACHED_REPO/" "$PATH_DESTINATION";
        echo -e "\t[Destination] $PATH_DESTINATION";
    fi;

    echo "";
}