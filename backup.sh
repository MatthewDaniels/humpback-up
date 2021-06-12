#!/bin/bash
################################ usage ###################################
# Option "-n" is "dry run".  Dry run example:
#   $ ~/scripts/backup_script ~ gs://wolfv-backup -n
# Real backups omit the third argument.  Live run example:
#   $ ~/scripts/backup_script ~ gs://wolfv-backup
# Example cron job that backs up twice a day at 03:52 and 15:52:
#	$ crontab -e
#	52 03,15 * * * ~/scripts/backup_script ~ gs://wolfv-backup

export CURRENT_WORKING_DIR=$(pwd)

#################################
# Imports
#################################
. ./includes/_formatting.sh
. ./includes/_utils.sh

echo
echo
echo -e "${GREEN}╭───────────────────────────────────────────────────────╮${NC}"
echo -e "${GREEN}├───────────── Google Cloud Storage Backup ─────────────┤${NC}"
echo -e "${GREEN}╰───────────────────────────────────────────────────────╯${NC}"
echo

getHelp() {
    echo
    echo -e "${RED}╭───────────────────────────────────╮${NC}"
    echo -e "${RED}├───────────── HELP!!! ─────────────┤${NC}"
    echo -e "${RED}╰───────────────────────────────────╯${NC}"
    echo
    echo -e "Option \"-n\" is \"dry run\".  Dry run example:"
    echo -e "    $ ~/scripts/backup_script ~ gs://wolfv-backup -n"
    echo
    echo -e "Real backups omit the third argument.  Live run example:"
    echo -e "  $ ~/scripts/backup_script ~ gs://wolfv-backup"
    echo
    echo -e "Example cron job that backs up twice a day at 03:52 and 15:52:"
    echo -e "	$ crontab -e"
    echo -e "	52 03,15 * * * ~/scripts/backup_script ~ gs://wolfv-backup"
    echo
}



############################### configuration ################################
SOURCE=$1
DESTINATION=$2
DRYRUN=$3
# BOTO_CONFIG="/home/wolfv/.boto"

# Google storage utility (requires full path, ~/gsutil/gsutil: No such file or directory).
GSUTIL="/usr/bin/gsutil"

# gsutil sends confirmation messages to stderr.  The quite option -q suppresses confirmations.
# if not dryrun
if [[ "$DRYRUN" != "-n" ]]
then
    GSUTIL="$GSUTIL -q -m"
fi

TARGET_GCLOUD_CONFIG="personal-backup"
TARGET_GCLOUD_PROJ="personal-backup-316604"

CURRENT_PROJECT_NAME=$(gcloud config list project | grep project | awk '{print $3}')
CURRENT_GCLOUD_CONFIG=$(gcloud config configurations list | grep True | awk '{print $1}')

# we need a target project
if [ -z "$TARGET_GCLOUD_PROJ" ]; then
    echo
    echo -e "${RED}Uh Oh!${NC} Require a target gcloud project"
    exit 1
fi


# Check the config
if [ -z "$TARGET_GCLOUD_CONFIG" ]; then
    # there is no target config - just check the project
    echo 
    echo -e "${YELLOW}Warning${NC}, the current Project ${GREEN}${CURRENT_PROJECT_NAME}${NC} does not match target project: '${GREEN}${TARGET_GCLOUD_PROJ}${NC}'."
    echo -e "The config project setting will be updated to use the provided target project '${TARGET_GCLOUD_PROJ}'."
    echo -e "Do you want to continue?"
    echo -e "(${YELLOW}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
    read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    gcloud config set project $TARGET_GCLOUD_PROJ
    $CURRENT_PROJECT_NAME = $TARGET_GCLOUD_PROJ
else
    if [[ $CURRENT_GCLOUD_CONFIG != $TARGET_GCLOUD_CONFIG ]]; then
        echo 
        echo -e "${YELLOW}Warning${NC}, the current GCLOUD Config ${GREEN}${CURRENT_GCLOUD_CONFIG}${NC} does not match target config: '${GREEN}${TARGET_GCLOUD_CONFIG}${NC}'."
        echo -e "The config settings will be updated to use the provided target config '${TARGET_GCLOUD_CONFIG}'."
        echo -e "Do you want to continue?"
        echo -e "(${YELLOW}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
        read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
        gcloud config configurations activate $TARGET_GCLOUD_CONFIG

        # now check the project
        CURRENT_PROJECT_NAME=$(gcloud config list project | grep project | awk '{print $3}')

        if [[ $CURRENT_PROJECT_NAME != $TARGET_GCLOUD_PROJ ]]; then
            echo 
            echo -e "${YELLOW}Warning${NC}, the current Project ${GREEN}${CURRENT_PROJECT_NAME}${NC} does not match target project: '${GREEN}${TARGET_GCLOUD_PROJ}${NC}'."
            echo -e "The config project setting will be updated to use the provided target project '${TARGET_GCLOUD_PROJ}'."
            echo -e "Do you want to continue?"
            echo -e "(${YELLOW}Note:${NC} choose 'No' to exit the script if you wish to change your gcloud configuration manually.)"
            read -p "(Y/N): "  confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
            gcloud config set project $TARGET_GCLOUD_PROJ
            $CURRENT_PROJECT_NAME = $TARGET_GCLOUD_PROJ
        fi
    fi
fi


# ERROR HANDLING for config setting
if [[ $? != 0 ]]; then
    echo
    echo -e "${RED}Uh Oh!${NC} Something went wrong... check the console."
    exit 1
fi


# These exclude patterns are Python regular expressions (not wildcards).
# The exclude patterns are named after the applications that generate them.
ARCHIVERS='.+\.7z$|.+\.dmg$|.+\.gz$|.+\.iso$|.+\.jar$|.+\.rar$|.+\.tar$|.+\.zip$'
ASTYLE='.+\.orig$'
COMPILERS='.+\.o$|.+\.exe$|.+\.hex$|.+\.out$'
DATABASES='.+\.sql$|.+\.sqlite$'
LOGS='.+\.log$'
MY_TAGS='.+_nobackup/|.+_nobackup$|.+_nobackup\..+|.+_old/|.+_old$|.+_old\..+|.+_book\..+'
NAUTILUS='.+copy\)'
VIM='.+~$|.+\.swp$|.+\.swo$|.+\.swn$'
GIT='\.git.*'
VENDOR_CODING='^.*vendor.*$|^.*node_modules.*$'
EXCLUDES="$ARCHIVERS|$ASTYLE|$COMPILERS|$DATABASES|$LOGS|$MY_TAGS|$NAUTILUS|$VIM|$GIT|$VENDOR_CODING"

# the inner parenthesis contains a list of files to backup.
EXCLUDE_HOME_FILES='^(?!(\.ackrc|\.bashrc|\.gitconfig|\.gitignore_global|\.vimrc)$).*'


############# TODO
# Create a file which is just `source | destination | params`
# Load in the shell script
# Iterate the lines
# Use awk '{print $1}' for source
# Use awk '{print $3}' for destination
# Use awk '{for(i=5;i<=NF;++i)print $i}' for params??? - will default to -c -C



########################## directories to backup #############################
# ~/ home directory
$GSUTIL rsync $DRYRUN -c -C       -x $EXCLUDE_HOME_FILES $SOURCE/ $DESTINATION/home/matt/

# ~/Documents
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES $SOURCE/Documents/ $DESTINATION/home/matt/Documents/

# $GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES $SOURCE/bu_test/ $DESTINATION/bu_test/

# # ~/bin
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES $SOURCE/bin/   $DESTINATION/home/matt/bin/
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES $SOURCE/conda-envs/   $DESTINATION/home/matt/conda-envs/

# ~/Pictures
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES $SOURCE/Pictures/  $DESTINATION/home/matt/Pictures/


# nginx config
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES /etc/nginx/  $DESTINATION/etc/nginx/
# usr loca bin
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES /usr/local/bin/  $DESTINATION/usr/local/bin/
# php setup
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES /etc/php/  $DESTINATION/etc/php/
# codes
$GSUTIL rsync $DRYRUN -c -C -e -r -x $EXCLUDES /mnt/04E42CB3E42CA93E/code/  $DESTINATION/code/

# bookmarks in Nautilus file manager, left pane
$GSUTIL rsync $DRYRUN -c -C -e    -x $EXCLUDES $SOURCE/.config/gtk-3.0/ $DESTINATION/home/matt/.config/gtk-3.0/

############################### confirmation #################################
# if not dryrun
if [[ "$DRYRUN" != "-n" ]]
then
    CONFIRMATION="$(date) $SOURCE  to  $DESTINATION  $DRYRUN"
    echo $CONFIRMATION >> ~/backup_log/backup.log
    echo $CONFIRMATION
fi
