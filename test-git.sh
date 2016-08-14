#!/bin/bash

# ################################################################ 
# SCAFFOLDING; NORMALLY PROVIDED BY LANYWARE; DONE TEMP FOR TESTS
# ################################################################
mkdir "$(realpath ~/test-cache)" --parents;
readonly CACHE_DIRECTORY=$(realpath ~/test-cache);
declare -a LANYWARE_GITHUB_IMPORT_HISTORY;
LANYWARE_GITHUB_IMPORT_HISTORY[0]="Array created at $(date)";

# Determine if a provided array (haystack) contains a value (needle)
# $1 Array (haystack) to check
# $2 Value (needle) to search for
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}
# ################################################################
# END SCAFFOLDING
# ################################################################


echo "===[ STARTING TEST ]===";
echo "STILL NEED FLAG TO PREVENT DOWNLOADS!!";
echo "STILL NEED FLAG TO PREVENT DOWNLOADS!!";
echo "";

# Downloads a repo from GitHub; caches it; and places the content in a specified directory
# $1 The GitHub repo name include the GitHub group (group/name)
# $2 The destination directory
function import_github_repo() {

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
        shift
        case in
            "--skip-remote" ;;
            "" ;;
        esac
    done;

    # PATH_CACHED_REPO 
    local PATH_CACHED_REPO="";
    PATH_CACHED_REPO=$(echo $GITHUB_REPO_NAME | sed -e 's/\//_/g');      # PATH_CACHED_REPO with "/" replaced with "_"
    PATH_CACHED_REPO="$CACHE_DIRECTORY/github.com/$PATH_CACHED_REPO";   # Append cache directory
    mkdir "$PATH_CACHED_REPO" --parents;

    # GFX Header
    echo "Importing GITHub Repo";
    echo -e "\t[Remote Source] $GITHUB_REPO_NAME";
    tput dim;
    echo -e "\t[Cache] $PATH_CACHED_REPO";
    tput sgr0;
    echo -e "\t[Destination] $PATH_DESTINATION";
    echo "";


    local REPO_UPATED;
    array_contains LANYWARE_GITHUB_IMPORT_HISTORY "$GITHUB_REPO_NAME" && REPO_UPATED=true || REPO_UPATED=false;

    if [ $REPO_UPATED = true ]; then
        echo -e "\tRepo already up to date; no need to redownload";
    elif [ $REPO_UPATED = false ]; then
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
            echo -e "\tRepo succesfully updated from GitHub.com";
        fi;

        if [[ ${#LANYWARE_GITHUB_IMPORT_HISTORY[@]} ]]; then
            LANYWARE_GITHUB_IMPORT_HISTORY+=("$GITHUB_REPO_NAME");
        else
            LANYWARE_GITHUB_IMPORT_HISTORY[0]="$GITHUB_REPO_NAME";
        fi;
    fi;

    # Copy from cache to the destination directory; excluding the ".git" directory
    rsync -aqr --exclude=.git "$PATH_CACHED_REPO/" "$PATH_DESTINATION"

    echo -e "";
}

import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "output-dir"
import_github_repo "LacledesLAN/gamesvr-srcds-metamod.linux" "output-dir"


# ########################################################################## 
# ENVIRONMENT TEAR DOWN; NORMALLY PROVIDED BY LANYWARE; DONE TEMP FOR TESTS
# ##########################################################################
unset LANYWARE_GITHUB_IMPORT_HISTORY;
# ##########################################################################
# END ENVIRONMENT TEAR DOWN
# ##########################################################################