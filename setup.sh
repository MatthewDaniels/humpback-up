#!/bin/bash

export CURRENT_WORKING_DIR=$(pwd)

#################################
# Imports
#################################
. ./includes/_formatting.sh
. ./includes/_utils.sh
. ./includes/_gcloud_setup.sh

#################################
# setup GCloud SDK
#################################
echo 
echo -e "Do you want to setup the ${YELLOW}Google Cloud SDK${NC}?"
read -p "(y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    gcloudSetup

    if [[ $? != 0 ]]; then
        setupErrorMessage "gcloud sdk"
        exit 1
    else
        echo
        echo -e "All done!"
    fi
fi


#################################
# Install OS software
#################################
echo 
echo -e "Do you want to install required ${YELLOW}OS Software${NC}?"
read -p "(y/N): " confirm

if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    basePackages

    if [[ $? != 0 ]]; then
        setupErrorMessage "OS Software"
        exit 1
    else
        echo
        echo -e "All done!"
    fi
fi

