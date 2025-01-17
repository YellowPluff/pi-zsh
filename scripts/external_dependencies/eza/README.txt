This tool requires building it yourself on the container. There are two ways to do that..

First Way:
    - Run the script ./scripts/external_dependencies/eza/upgrade_eza.zsh
    - This will handle everything
Second Way:
    - Manually follow the instructions below
    - Note: The script above is just an automated version of the below instructions.
        So in a sense, the below instrucitons are pseudo code and can be used to debug if something
        goes wrong.

1. Boot into centos7 container
2. Run the command "sudo su" to log in as the super user
3. Run the command "yum install -y cargo"
5. Run the command "exit" to get back to the user vagrant
6. Get the tag of the latest release from (https://github.com/eza-community/eza/releases/latest)
    then git clone it with the syntax "git clone --branch <tag_name> git clone https://github.com/eza-community/eza.git"
7. In the directory with the code run the command "cargo install --path ."
9. Copy/Replace the ~/.cargo/bin/eza binary into the wcs-zsh repository in external_dependencies/bin/
10. Confirm that the updated binary works on all supported OS (Centos7, Rocky8, Rocky9)
11. Submit eza version to EFOSS for approval
12. Submit eza version to security for SSP-39 approval
13. Submit a merge request