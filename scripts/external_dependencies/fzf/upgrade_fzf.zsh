#!/usr/bin/zsh

# Ensure this is running on CentOS7
OPERATING_SYSTEM="$(cat /etc/os-release | grep -i "CentOS Linux 7")"
if [ ! $OPERATING_SYSTEM ];
then
    echo "You must be in a CentOS 7 container to run this script!!"
    exit 1
fi

THIS_SCRIPT_PATH=${0:a:h}

# Check the currently installed version of fzf
CURRENTLY_INSTALLED_FZF_VERSION="$($THIS_SCRIPT_PATH/../bin/fzf --version | cut -d " " -f1)"

# Make a temp directory for cloning the fzf repo and building it
cd
mkdir automation_upgrade_fzf
cd automation_upgrade_fzf
git clone https://github.com/junegunn/fzf.git
cd fzf

# Parse for the latest release tag
git fetch origin master --tags
LATEST_RELEASE_TAG="$(git tag --sort=creatordate | tail -1)"

echo "DEBUG: CURRENTLY_INSTALLED_FZF_VERSION = $CURRENTLY_INSTALLED_FZF_VERSION"
echo "DEBUG:              LATEST_RELEASE_TAG = $LATEST_RELEASE_TAG"

# If you have the latest release already, nothing to do..
if [[ $CURRENTLY_INSTALLED_FZF_VERSION == $LATEST_RELEASE_TAG ]];
then
    echo "You're already running the newest version of fzf.."
    echo "Cleaning up and exiting..."
    
    # Cleanup build repo
    cd
    rm -rf automation_upgrade_fzf

    exit 0
else
    # Install make and go
    sudo yum install -y make
    sudo yum install -y go

    # Check out the repo to that release
    git checkout $LATEST_RELEASE_TAG

    # Build fzf
    make
    make install

    # Copy the new binary to the repository
    rm $THIS_SCRIPT_PATH/../bin/fzf
    cp ./bin/fzf $THIS_SCRIPT_PATH/../bin/fzf

    # Uninstall make and go
    sudo yum remove -y make
    sudo yum remove -y go

    # Cleanup build repo
    cd
    rm -rf automation_upgrade_fzf

    echo "\n"
    echo "##############################################################################################################"
    echo "#                                         Finished upgrade of fzf!                                           #"
    echo "##############################################################################################################"
    echo "# Upgraded from version $CURRENTLY_INSTALLED_FZF_VERSION to $LATEST_RELEASE_TAG"
    echo "# REMEMBER!! You must submit the new version for EFOSS and security approval prior to uploading it to SSP-39"
    echo "\n"
fi