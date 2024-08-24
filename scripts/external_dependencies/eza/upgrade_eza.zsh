#!/usr/bin/zsh

# Ensure this is running on CentOS7
OPERATING_SYSTEM="$(cat /etc/os-release | grep -i "CentOS Linux 7")"
if [ ! $OPERATING_SYSTEM ];
then
    echo "You must be in a CentOS 7 container to run this script!!"
    exit 1
fi

THIS_SCRIPT_PATH=${0:a:h}

# Check the currently installed version of eza
CURRENTLY_INSTALLED_EZA_VERSION="$($THIS_SCRIPT_PATH/../bin/eza --version | grep -oP "v[0-9]*.[0-9]*.[0-9]*")"

# Make a temp directory for cloning the bat repo and building it
cd
mkdir automation_upgrade_eza
cd automation_upgrade_eza
git clone https://github.com/eza-community/eza.git
cd eza

# Parse for the latest release tag
git fetch origin main --tags
LATEST_RELEASE_TAG="$(git tag --sort=creatordate | tail -1)"

echo "DEBUG: CURRENTLY_INSTALLED_EZA_VERSION = $CURRENTLY_INSTALLED_EZA_VERSION"
echo "DEBUG:              LATEST_RELEASE_TAG = $LATEST_RELEASE_TAG"

# If you have the latest release already, nothing to do..
if [[ $CURRENTLY_INSTALLED_EZA_VERSION == $LATEST_RELEASE_TAG ]];
then
    echo "You're already running the newest version of eza.."
    echo "Cleaning up and exiting..."
    
    # Cleanup build repo
    cd
    rm -rf automation_upgrade_eza

    exit 0
else
    # Install cargo
    sudo yum install -y cargo

    # Check out the repo to that release
    git checkout $LATEST_RELEASE_TAG

    # Build bat
    cargo install --path .

    # Copy the new binary to the repository
    rm $THIS_SCRIPT_PATH/../bin/eza
    cp ~/.cargo/bin/eza $THIS_SCRIPT_PATH/../bin/eza

    # Uninstall cargo
    sudo yum remove -y cargo

    # Cleanup build repo
    cd
    rm -rf automation_upgrade_eza

    echo "\n"
    echo "##############################################################################################################"
    echo "#                                         Finished upgrade of eza!                                           #"
    echo "##############################################################################################################"
    echo "# Upgraded from version $CURRENTLY_INSTALLED_EZA_VERSION to $LATEST_RELEASE_TAG"
    echo "# REMEMBER!! You must submit the new version for EFOSS and security approval prior to uploading it to SSP-39"
    echo "\n"
fi