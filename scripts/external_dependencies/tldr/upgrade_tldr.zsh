#!/usr/bin/zsh

# Ensure this is running on Rocky Linux 8
OPERATING_SYSTEM="$(cat /etc/os-release | grep -i "Rocky Linux 8")"
if [ ! $OPERATING_SYSTEM ];
then
    echo "You must be in a Rocky Linux 8 container to run this script!!"
    exit 1
fi

THIS_SCRIPT_PATH=${0:a:h}

# Check the currently installed version of tldr
CURRENTLY_INSTALLED_TLDR_VERSION="$($THIS_SCRIPT_PATH/../bin/tldr_binary --version | cut -d " " -f2)"

# Make a temp directory for cloning the tldr repo and building it
cd
mkdir automation_upgrade_tldr
cd automation_upgrade_tldr
git clone https://github.com/tldr-pages/tlrc.git
cd tlrc

# Parse for the latest release tag
git fetch origin main --tags
LATEST_RELEASE_TAG="$(git tag --sort=creatordate | tail -1)"

echo "DEBUG: CURRENTLY_INSTALLED_TLDR_VERSION = $CURRENTLY_INSTALLED_TLDR_VERSION"
echo "DEBUG:               LATEST_RELEASE_TAG = $LATEST_RELEASE_TAG"

# If you have the latest release already, nothing to do..
if [[ $CURRENTLY_INSTALLED_TLDR_VERSION == $LATEST_RELEASE_TAG ]];
then
    echo "You're already running the newest version of tldr.."
    echo "Cleaning up and exiting..."
    
    # Cleanup build repo
    cd
    rm -rf automation_upgrade_tldr

    exit 0
else
    # Install cargo and unzip
    sudo dnf install -y cargo
    sudo dnf install -y unzip

    # Check out the repo to that release
    git checkout $LATEST_RELEASE_TAG

    # Build tldr
    cargo build

    # Copy the new binary to the repository
    rm $THIS_SCRIPT_PATH/../bin/tldr
    cp ./target/debug/tldr $THIS_SCRIPT_PATH/../bin/tldr_binary

    # Download and unzip the newest tldr pages directly into the repository
    cd $THIS_SCRIPT_PATH
    rm -rf tlrc
    mkdir tlrc
    cd tlrc
    curl --location --output ./pages.zip "https://github.com/tldr-pages/tldr/releases/latest/download/tldr-pages.en.zip"
    unzip ./pages.zip -d ./pages.en/
    rm ./pages.zip
    cd pages.en
    command ls | grep -xvP "(common|linux)" | xargs rm -rf

    # Uninstall cargo and unzip
    sudo dnf remove -y cargo
    sudo dnf remove -y unzip

    # Cleanup build repo
    cd
    rm -rf automation_upgrade_tldr

    echo "\n"
    echo "##############################################################################################################"
    echo "#                                        Finished upgrade of tldr!                                           #"
    echo "##############################################################################################################"
    echo "# Upgraded from version $CURRENTLY_INSTALLED_TLDR_VERSION to $LATEST_RELEASE_TAG"
    echo "# REMEMBER!! You must submit the new version for EFOSS and security approval prior to uploading it to SSP-39"
    echo "\n"
fi
