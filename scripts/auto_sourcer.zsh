# Save off the SHA of the current .zshrc file
__zshrc_sha=$(sha1sum $HOME/.zshrc)

# Save off the SHA of the current prompt.zsh file
__prompt_sha=$(sha1sum $HOME/zsh/prompt.zsh)

# Save off the SHA of the current aliases.zsh file
__aliases_sha=$(sha1sum $HOME/zsh/aliases.zsh)

# Save off the SHA of the current functions.zsh file
__functions_sha=$(sha1sum $HOME/zsh/functions.zsh)

function __check_and_source_user_files
{
    # Flag to tell us if a shell reload is needed because of a change
    local RELOAD_ZSH=0

    # Check the SHA of the .zshrc file
    # If it changed, alert the user and reload ZSH.
    local updated_zshrc_sha=$(sha1sum $HOME/.zshrc)
    if [[ "$__zshrc_sha" != "$updated_zshrc_sha" ]];
    then
        echo "Detected a change in $HOME/.zshrc."

        # Set the reload flag to 1
        RELOAD_ZSH=1
    fi

    # Check the SHA of the prompt.zsh file
    # If it changed, alert the user, source it, and update the value
    local updated_prompt_sha=$(sha1sum $HOME/zsh/prompt.zsh)
    if [[ "$__prompt_sha" != "$updated_prompt_sha" ]];
    then
        echo "Detected a change in $HOME/zsh/prompt.zsh."

        # Save off user defined prompt for use in the alert system
        USER_PROMPT=$PROMPT

        # Set alert banner
        _set_prompt_alert

        # Save the users changes to prompt.zsh into their git history
        (( $GIT_BACKUP_HOME_ZSH_DIR == 1 )) && __commit_user_prompt_file

        # Set the reload flag to 1
        RELOAD_ZSH=1
    fi

    # Check the SHA of the aliases.zsh file
    # If it changed, alert the user, source it, and update the value
    local updated_aliases_sha=$(sha1sum $HOME/zsh/aliases.zsh)
    if [[ "$__aliases_sha" != "$updated_aliases_sha" ]];
    then
        echo "Detected a change in $HOME/zsh/aliases.zsh."

        # Save the users changes to aliases.zsh into their git history
        (( $GIT_BACKUP_HOME_ZSH_DIR == 1 )) && __commit_user_aliases_file

        # Set the reload flag to 1
        RELOAD_ZSH=1
    fi

    # Check the SHA of the functions.zsh file
    # If it changed, alert the user, source it, and update the value
    local updated_functions_sha=$(sha1sum $HOME/zsh/functions.zsh)
    if [[ "$__functions_sha" != "$updated_functions_sha" ]];
    then
        echo "Detected a change in $HOME/zsh/functions.zsh."

        # Save the users changes to functions.zsh into their git history
        (( $GIT_BACKUP_HOME_ZSH_DIR == 1 )) && __commit_user_functions_file

        # Set the reload flag to 1
        RELOAD_ZSH=1
    fi

    # Reload ZSH if there was a change
    [[ $RELOAD_ZSH == 1 ]] && echo "Reloading WCS-ZSH..." && exec zsh -l
}
add-zsh-hook precmd __check_and_source_user_files

function __init_git_in_home_zsh
{
    # Check that their ~/zsh/ is a git directory.
    if [[ ! -d "$HOME/zsh/.git" ]];
    then
        # Init the git repo
        $(cd $HOME/zsh/ && git init > /dev/null 2>&1)

        # Generate the .gitignore file
        $(cd $HOME/zsh/ && echo ".user_tracker_wcs_zsh_*" > .gitignore)

        # Add all the files to git tracking
        $(cd $HOME/zsh/ && git add .gitignore > /dev/null 2>&1)
        $(cd $HOME/zsh/ && git add prompt.zsh > /dev/null 2>&1)
        $(cd $HOME/zsh/ && git add aliases.zsh > /dev/null 2>&1)
        $(cd $HOME/zsh/ && git add functions.zsh > /dev/null 2>&1)

        # Do the initial git commit
        $(cd $HOME/zsh/ && git commit -m "Initialized git repository $HOME/zsh/" > /dev/null 2>&1)
    fi
}

function __commit_user_prompt_file
{
    echo "Auto-commiting it to local git for history tracking."

    __init_git_in_home_zsh

    # git add on prompt file
    $(cd $HOME/zsh/ && git add prompt.zsh > /dev/null 2>&1)

    # Git commit on prompt file
    $(cd $HOME/zsh/ && git commit -m "Updated prompt.zsh" > /dev/null 2>&1)
}

function __commit_user_aliases_file
{
    echo "Auto-commiting it to local git for history tracking."

    __init_git_in_home_zsh

    # git add on aliases file
    $(cd $HOME/zsh/ && git add aliases.zsh > /dev/null 2>&1)

    # Git commit on aliases file
    $(cd $HOME/zsh/ && git commit -m "Updated aliases.zsh" > /dev/null 2>&1)
}

function __commit_user_functions_file
{
    echo "Auto-commiting it to local git for history tracking."

    __init_git_in_home_zsh

    # git add on functions file
    $(cd $HOME/zsh/ && git add functions.zsh > /dev/null 2>&1)

    # Git commit on functions file
    $(cd $HOME/zsh/ && git commit -m "Updated functions.zsh" > /dev/null 2>&1)
}