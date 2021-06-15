#!/usr/bin/env bash


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

########################################################
# INSTALL BASE OS PACKAGES
########################################################
function basePackages() {

    local BASE_PACKAGES=("mawk")
    local BASE_PACKAGES_TO_INSTALL

    for PKG_COMMAND in "${BASE_PACKAGES[@]}"
    do
        if [ $(commandExists "${PKG_COMMAND}") == "n" ]; then
        # if [ $(aptPackageInstalled "${PKG_COMMAND}") == "n" ]; then
            echo
            echo "${PKG_COMMAND} could not be found... let's install it"
            
            if [[ -z "$BASE_PACKAGES_TO_INSTALL" ]]; then
                BASE_PACKAGES_TO_INSTALL=()
            fi
            BASE_PACKAGES_TO_INSTALL+=("${PKG_COMMAND}")
        fi
    done

    if [[ -z "$BASE_PACKAGES_TO_INSTALL" ]]; then
        echo
        echo "No extra packages to install... continuing."
        echo
    else
        showInstallOrSetupMessage "install" "$( IFS=$' '; echo "${BASE_PACKAGES_TO_INSTALL[*]}" )"
        sudo apt install -y "${BASE_PACKAGES_TO_INSTALL[@]}"
    fi
}

# function osSoftwareInstall() {

#     # FOLDERS
#     echo
#     echo -e "${YELLOW}╭────────────────────────────────────────╮${NC}"
#     echo -e "${YELLOW}├─────────── GCLOUD SDK SETUP ───────────┤${NC}"
#     echo -e "${YELLOW}╰────────────────────────────────────────╯${NC}"
#     echo

#     SOFTWARE_PACKAGES=""

#     # GCLOUD
#     if [ $(commandExists "awk") == "n" ]; then
#         SOFTWARE_PACKAGES+="awk "
#     fi

#     if [[ -v SOFTWARE_PACKAGES ]] && [[ "$SOFTWARE_PACKAGES" != "" ]]; then
#         sudo apt-get install --no-install-recommends --no-install-suggests -y $SOFTWARE_PACKAGES
#     fi
# }