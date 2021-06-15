#!/usr/bin/env bash

####################
## RUNTIME SETTINGS

# the GCloud project to use
# configurations can be updated to use different projects, so checks are put in to ensure the correct config AND project are used
export GCLOUD_PROJECT

# this is the Google Cloud Storage bucket where the files will be uploaded to
# it is populated with a runtime variables and has no default (it is requried)
export DESTINATION_BUCKET

# the source file that contains all the source > destination mapping
export SOURCE_FILE

# whether or not this run will be a dry run - default is no (NOT y or yes or true or 1)
export DRYRUN
# whether or not the run will be quiet (ie: using the gsutil -q parameter) - default is yes (NOT n or no or false or 0)
export QUIET


####################
## CONFIG SETTINGS

# the [gcloud sdk configuration](https://cloud.google.com/sdk/docs/configurations) to use 
# can be set via runtime vars
# default is "personal-backups"
export GCLOUD_CONFIG_NAME="personal-backups"

# Google storage utility (requires full path, ~/gsutil/gsutil: No such file or directory).
export GSUTIL="/usr/bin/gsutil"

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

export BASE_EXCLUDES="$ARCHIVERS|$ASTYLE|$COMPILERS|$DATABASES|$LOGS|$MY_TAGS|$NAUTILUS|$VIM|$GIT|$VENDOR_CODING"
