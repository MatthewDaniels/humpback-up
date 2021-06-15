#!/usr/bin/env bash

# sends a single line from the file to gcloud command - may take a while to complete
# param is the entire LINE
function humpbackup() {
    # get the value of the parameter (the whole line), split by || & pick the appropriate index (1 - 4), trim leading & trailing whitespace
    local SOURCE=$(echo -n "$1" | awk -F"\|\|" '{print $1}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')
	
    local DESTINATION=$DESTINATION_BUCKET
    DESTINATION+=$(echo -n "$1" | awk -F"\|\|" '{print $2}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')

	local EXTRA_PARAMS=$(echo -n "$1" | awk -F"\|\|" '{print $3}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')
	local EXTRA_EXCLUSIONS=$(echo -n "$1" | awk -F"\|\|" '{print $4}' | awk '{ gsub(/^[ \t]+|[ \t]+$/, ""); print }')

    if [[ -v EXTRA_EXCLUSIONS ]] && [[ "$EXTRA_EXCLUSIONS" != "" ]]; then
        local EXCLUSIONS="$BASE_EXCLUDES|$EXTRA_EXCLUSIONS";
    else
        local EXCLUSIONS="$BASE_EXCLUDES"
    fi

    # if [[ -v EXTRA_EXCLUSIONS ]] && [[ "$EXTRA_EXCLUSIONS" != "" ]]; then
    #     local EXCLUSIONS="$EXCLUDES|$EXTRA_EXCLUSIONS";
    # else
    #     local EXCLUSIONS="$EXCLUDES"
    # fi

    if [[ -v QUIET ]] && [[ "$QUIET" != "n" ]]; then
        echo -e "${UNDERLINE}Source:${NC} $SOURCE"
        echo -e "${UNDERLINE}Destination:${NC} $DESTINATION"
        echo -e "${UNDERLINE}Extra Parameters:${NC} $EXTRA_PARAMS"
        echo -e "${UNDERLINE}Exclusions:${NC} ${YELLOW_BOLD}$EXCLUSIONS${NC}"

        echo
        echo -e "Uploading..."
    fi

    $GSUTIL rsync $DRYRUN -c -C $EXTRA_PARAMS -x $EXCLUSIONS $SOURCE $DESTINATION
    
    # ERROR HANDLING
    if [[ $? != 0 ]]; then

        genericError "Something went wrong when atempting to send the data to GCS."

        return $?
    fi

    # if not dryrun=
    if [[ -v DRYRUN ]] && [[ "$DRYRUN" != "y" ]]; then
        # do we export the dry run config?
        local CONFIRMATION="$(date) $SOURCE  to  $DESTINATION ; Dry run: $DRYRUN ;  Extra Params: $EXTRA_PARAMS; Exclusions: $EXCLUSIONS"
        # $LOG+="$(echo $CONFIRMATION)"

        logMessage $CONFIRMATION

        echo $CONFIRMATION >> "$LOG_FOLDER/backup-dryrun.$NOW_STRING.log"
    else
        local CONFIRMATION="$(date) $SOURCE  to  $DESTINATION  $DRYRUN"
        
        logMessage $CONFIRMATION

        echo $CONFIRMATION >> "$LOG_FOLDER/backup.$NOW_STRING.log"
    fi

    echo
}
