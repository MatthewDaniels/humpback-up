#!/usr/bin/env bash

export CURRENT_WORKING_DIR=$(pwd)

#################################
# Imports
#################################
. $CURRENT_WORKING_DIR/includes/_formatting.sh
. $CURRENT_WORKING_DIR/includes/_variables.sh
. $CURRENT_WORKING_DIR/includes/_utils.sh
. $CURRENT_WORKING_DIR/includes/_sender.sh


# Parse the input parameters
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -q|--quiet)
    QUIET="y"
    shift # past argument
    shift # past value
    ;;
    -dr|--dry_run)
    DRYRUN="-n"
    shift # past argument
    shift # past value
    ;;
    -p|--project)
    GCLOUD_PROJECT="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--file)
    SOURCE_FILE="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--destination)
    DESTINATION_BUCKET="$2"
    shift # past argument
    shift # past value
    ;;
    -cn|--config_name)
    GCLOUD_CONFIG_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -y|--always_yes)
    ALWAYS_YES="y"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}"

# error - need to set a dataset!
if [ -z "$SOURCE_FILE" ]; then
    genericError "no source file specified, please use the '${YELLOW_BOLD}-f${NC}' or '${YELLOW_BOLD}--file${NC}' parameter to specify the absolute file location."
    
    exit 1
fi

# error - need to set a table or view!
if [ -z "$DESTINATION_BUCKET" ]; then

    genericError "no destination bucket specified, please use the '${YELLOW_BOLD}-d${NC}' or '${YELLOW_BOLD}--destination${NC}' parameter to specify the destination bucket."

    exit 1
fi

#######################################
## CHECK AND SET THE GCLOUD CONFIGURATION

CURRENT_PROJECT_NAME=$(gcloud config list project | grep project | awk '{print $3}')
CURRENT_GCLOUD_CONFIG=$(gcloud config configurations list | grep True | awk '{print $1}')

# Check the config
if [ -z "$GCLOUD_CONFIG_NAME" ]; then
    # should we skip the ask?
    if [ $ALWAYS_YES != "-y" ]; then
        # there is no target config - just check the project
        echo 
        echo -e "${YELLOW_BOLD}Warning${NC}, there is no gcloud configuration set - using the current config ${GREEN}${CURRENT_GCLOUD_CONFIG}${NC}."
        echo -e "The current config project setting will be used '${CURRENT_PROJECT_NAME}'."
        echo -e "Do you want to continue?"
        echo -e "(${YELLOW_BOLD}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
        read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    fi
else
    if [[ $CURRENT_GCLOUD_CONFIG != $GCLOUD_CONFIG_NAME ]]; then
        echo 
        echo -e "${YELLOW_BOLD}Warning${NC}, the current GCLOUD Config ${GREEN}${CURRENT_GCLOUD_CONFIG}${NC} does not match target config: '${GREEN}${GCLOUD_CONFIG_NAME}${NC}'."
        echo -e "The config settings will be updated to use the provided target config '${GCLOUD_CONFIG_NAME}'."

        # should we skip the ask?
        if [ $ALWAYS_YES != "-y" ]; then
            echo -e "Do you want to continue?"
            echo -e "(${YELLOW_BOLD}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
            read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        fi
        gcloud config configurations activate $GCLOUD_CONFIG_NAME

        # now check the project
        CURRENT_PROJECT_NAME=$(gcloud config list project | grep project | awk '{print $3}')
        if [[ -v GCLOUD_PROJECT ]]; then
            if [[ $CURRENT_PROJECT_NAME != $GCLOUD_PROJECT ]]; then
                echo 
                echo -e "${YELLOW_BOLD}Warning${NC}, the current Project ${GREEN}${CURRENT_PROJECT_NAME}${NC} does not match target project: '${GREEN}${GCLOUD_PROJECT}${NC}'."
                echo -e "The config project setting will be updated to use the provided target project '${GCLOUD_PROJECT}'."

                # should we skip the ask?
                if [ $ALWAYS_YES != "-y" ]; then
                    echo -e "Do you want to continue?"
                    echo -e "(${YELLOW_BOLD}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
                    read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
                fi
                gcloud config set project $GCLOUD_PROJECT
                $CURRENT_PROJECT_NAME = $GCLOUD_PROJECT
            fi
        fi
    fi
fi

# ERROR HANDLING for config setting
if [[ $? != 0 ]]; then
    genericError "Something went wrong when trying to set the gcloud configuration or project... check the console."
    exit 1
fi


#######################################
## START

if [[ -v QUIET ]] && [[ "$QUIET" = "n" ]]; then
    logMessage
    logMessage
    logMessage "${GREEN}╭───────────────────────────────────────────────────────╮${NC}"
    logMessage "${GREEN}├───────────── Google Cloud Storage Backup ─────────────┤${NC}"
    logMessage "${GREEN}╰───────────────────────────────────────────────────────╯${NC}"
    logMessage
fi

# read the file into an array with each line representing an element
readarray -t backup_sources < $SOURCE_FILE

# each element in the sources array is a ROW
declare -p backup_sources

# setup the gsutil command
GSUTIL="$GSUTIL -m"

if [[ -z "${DRYRUN}" ]] || [[ "$DRYRUN" != "-n" ]]; then
    # if it is NOT a dry run - we can set the quiet mode on (ie: dry run shoud NOT be quiet)
    if [[ -z "${QUIET}" ]] || [[ "$QUIET" != "n" ]]; then
        # we want to be quiet - add the param to 
        # gsutil sends confirmation messages to stderr.  The quite option -q suppresses confirmations.
        GSUTIL+=" -q"
    fi
fi

# iterate the array & send it to GSUTIL
for f in "${backup_sources[@]}"
do
	humpbackup "$f"

    # ERROR HANDLING - PER LINE
    if [[ $? != 0 ]]; then
        echo "Something went wrong with: \"$f\"" >> "$LOG_FOLDER/errors.$NOW_STRING.log"
    fi

done
