# This logic is for searching aliases when a user types a command.
# If the typed command matches an alias, it'll print a tip to use the alias instead.
function __search_and_print_alias_tip
{

    # 1 = False
    FOUND_MATCH=1

    local USER_COMMAND=$1          # User entered command

    # Iterate over all user aliases
    for alias in ${(k)aliases};
    do
        local USER_ALIAS=$alias
        local USER_ALIAS_EXPANDED=$aliases[$alias]
        
        # if echo Hello = echo Hello
        if [[ $USER_COMMAND == $USER_ALIAS_EXPANDED ]];
        then
            # 0 = True
            FOUND_MATCH=0
            echo " ++ Alias Tip:$BGreen $USER_ALIAS $Color_Off" # Alert the user to use alias "hi"
            break
        fi
    done

    return $FOUND_MATCH
}


function __zsh_alias_finder_runner
{
    ######
    # This function will print a tip line if the user typed a command that they have an alias for.
    # It works by doing a direct search first. If that fails then it'll fall into 1 of 2 paths...
    # 1. If the command ended with a /, remove it and search again.
    # 2. If the command didn't end with a /, add it and search again.
    
    # While we could expand on this, I've opted not to. After testing I found that anything more
    # starts to slow down the terminal.

    # Though if we wanted to flesh out this code, we could make it run asynchronously.
    # Perhaps a future feature.
    ######

    local USER_COMMAND=$1          # User entered command
    local USER_COMMAND_EXPANDED=$2 # Shell expands the user command and stores it in $2

    if [[ $USER_COMMAND == $USER_COMMAND_EXPANDED ]];
    then
        # Did not type in an alias, need to search aliases

        # If the user command($1) and the user command expanded($2) match,
        # this means the user DID NOT type in an alias

        # Example 1: Assuming alias hi='echo Hello'
        # User input command: hi
        # User input command expanded: echo Hello
        # hi != echo Hello, which means hi is an alias and no searching is neccessary
        # --
        # Example 2: Assuming alias hi='echo Hello'
        # User input command: hey
        # User input command expanded: hey
        # hey = hey, so hey IS NOT an alias, so you'll search aliases to find a match for hey

        __search_and_print_alias_tip $USER_COMMAND
        FOUND_MATCH_RETURN=$?

        if [[ $FOUND_MATCH_RETURN != 0 ]];
        then
            # This is where special conditions start.
            # Condition 0: ~
            if [[ $1 == *~* ]];
            then
                # Convert the ~ to $HOME and try again.
                USER_COMMAND=${USER_COMMAND//'~'/$HOME}
            fi

            # Condition 1: The user command was 'cd' and ends with a /
            if [[ $1 == cd* ]] && [[ $1 == */ ]];
            then
                # If the user command ends with a /, then strip the / and try to match.
                USER_COMMAND=${USER_COMMAND[1,-2]}
            # Condition 2: The user command was 'cd' but doesn't end with a /
            elif [[ $1 == cd* ]];
            then
                # If the user command does not end with a /, then add a / and try to match.
                USER_COMMAND=$USER_COMMAND/
            fi
            
            # Attempt a search again after a / was removed/added.
            __search_and_print_alias_tip $USER_COMMAND
        fi
    fi
}

if (( $ALIAS_TIP_FEATURE == 1 ));
then
    add-zsh-hook preexec __zsh_alias_finder_runner
fi