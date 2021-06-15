#!/usr/bin/env bash

export GCLOUD_CONFIG_NAME='personal-backups'

export DESTINATION_BUCKET='gs://uw1_test_bucket_backup'

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

export EXCLUDES="$ARCHIVERS|$ASTYLE|$COMPILERS|$DATABASES|$LOGS|$MY_TAGS|$NAUTILUS|$VIM|$GIT|$VENDOR_CODING"
