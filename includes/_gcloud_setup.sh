#!/bin/bash


function gcloudSetup() {

    # FOLDERS
    echo
    echo -e "${YELLOW}╭────────────────────────────────────────╮${NC}"
    echo -e "${YELLOW}├─────────── GCLOUD SDK SETUP ───────────┤${NC}"
    echo -e "${YELLOW}╰────────────────────────────────────────╯${NC}"
    echo


    # GCLOUD
    if [ $(commandExists "gcloud") == "n" ]; then

        showInstallOrSetupMessage "add the" "Cloud SDK repo"
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

        showInstallOrSetupMessage "import the" "Google Cloud public key"
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
        
        showInstallOrSetupMessage "install" "gcloud"
        sudo apt-get update && sudo apt-get install google-cloud-sdk
    fi

    # init gcloud
    gcloud init --skip-diagnostics

    # create the configs
    gcloud init --skip-diagnostics --configuration $GCLOUD_CONFIG_NAME
}
