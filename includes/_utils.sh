#!/usr/bin/env bash

function genericError() {
    local ERROR_MESSAGE=$1

    if [[ -v QUIET ]] && [[ "$QUIET" != "n" ]]; then
        echo
        echo -e "${RED}Uh Oh!${NC} - ${ERROR_MESSAGE}"
        echo
    fi
}

function logMessage() {
    local LOG_MESSAGE=$1

    if [[ -v QUIET ]] && [[ "$QUIET" != "n" ]]; then
        echo
        echo -e "${LOG_MESSAGE}"
        echo
    fi
}


function setupErrorMessage() {
    local ERRORED_PROCESS=$1

    echo
    echo -e "${RED}Uh Oh!${NC} Something went wrong when executing the following process: ${ERRORED_PROCESS}... check the console."
    echo
}

function showInstallOrSetupMessage() {
    # should be "install" or "setup"
    local VERB_MESSAGE=$1
    local PACKAGE_OP=$2

    echo
    echo -e "Time to ${VERB_MESSAGE} ${GREEN}${PACKAGE_OP}${NC} - watch the console..."
    echo
}

function commandExists() {
    local PKG_COMMAND=$1

    if ! command -v $PKG_COMMAND &> /dev/null; then
        echo "n"
        return 1
    else
        echo "y"
        return 0
    fi
}

function aptPackageInstalled() {
    local PKG_COMMAND=$1
    local STRING_TO_CHECK=$(apt -qq $PKG_COMMAND 2>/dev/null | grep "installed")

    if [[ $STRING_TO_CHECK =~ "installed" ]]; then
        echo "y"
        return 0
    else
        echo "n"
        return 1
    fi
}

function cloneRepoInto() {
    local REPO_PATH=$1
    local LOCAL_PATH=$2

    git clone $1 $2
}

function arrayContains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

