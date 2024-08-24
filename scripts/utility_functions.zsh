function _copy_function
{
    test -n "$(declare -f "$1")" || return 
    eval "${_/$1/$2}"
}

function _rename_function
{
    _copy_function "$@" || return
    unset -f "$1"
}

# This function shouldn't be called directly.
# To set the banner alert, you should set the PROMPT_ALERT variable
function _set_prompt_alert
{
    # Reset the prompt back to the user prompt
    PROMPT=$USER_PROMPT

    # Then set the banner if there is a banner to display
    if [[ $PROMPT_ALERT != "" ]];
    then
        local banner_message="%K{black}%F{red}%B$PROMPT_ALERT%b%f%k"
        local new_line=$'\n'

        PROMPT=" $banner_message$new_line$PROMPT"
    fi
}
add-zsh-hook precmd _set_prompt_alert

function __do_git_checkout_based_on_jira_id
{
    # Store the branch the user is trying to check out to.
    local checkout_to_branch_name=$2

    # First, see if the user has a branch name of just numbers
    local found_branch="$(git branch | grep -m 1 -P "^[[:blank:]]*$checkout_to_branch_name" | sed 's/ //g')"

    # If the user has a branch that's just a number, check that out
    if [[ $found_branch != "" ]];
    then
        # Run the git command the user intended
        command git $@
    else
        # If there is a branch by the name CSLSAARES-checkout_to_branch_name
        # This is specific to Ares so that we don't break git for other people using our product
        found_branch="$(git branch | grep -m 1 -P "^[[:blank:]]*CSLSAARES-$checkout_to_branch_name" | sed 's/ //g')"

        if [[ $found_branch != "" ]];
        then
            command git checkout $found_branch
        else
            # Run the git command the user intended
            command git $@
        fi
    fi
}