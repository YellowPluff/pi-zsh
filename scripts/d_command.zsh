# Directory Stack Options
# The following options are necessary to support directory stack usage
setopt AUTO_PUSHD        # Automatically push directories onto the directory stack
setopt AUTO_CD           # If a directory is typed as the only command cd into that directory
setopt PUSHD_IGNORE_DUPS # Ignore duplicate entries in the directory stack
setopt PUSHD_SILENT      # Push directories onto the stack silently
setopt PUSHD_MINUS       # Exchange meaning of + and - when specifying dir in dir stack (aligns with directory stack aliases)

# The 'd' command

# Global variable for tracking where the user is travelling to using the 'd' command.
# Used for un-setting the travel function that gets created dynamically.
D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO=-1

# Global variable for tracking if the user has their own function that could get over-written from this logic.
# Used to ensure we keep the user defined function.
USER_DEFINED_FUNCTION=false

function d
{
    echo "_________ Enter number to navigate to directory... _________"
    dirs -v | head -$USER_DIRECTORY_STACK_SIZE
}

function __directory_navigate_to_user_number_dir
{
    # The following conditions must be met in order to execute command
    # as directory navigation.
    # If user input is a number
    # If user input is less than 'd' stack size value
    # If the last command was 'd'

    NUMERIC_REGULAR_EXPRESSION='^[0-9]+$'
    if [[ $1 =~ $NUMERIC_REGULAR_EXPRESSION ]];
    then
        if [[ $1 -lt $USER_DIRECTORY_STACK_SIZE ]];
        then
            if [[ $USER_LAST_COMMAND = 'd' ]];
            then
                if typeset -f $1 > /dev/null;
                then
                    # The user has a function defined for the number they're inputting
                    # So we need to rename their function for this d-command logic to process
                    # Then we can rename the user function back after we cleanup from this logic
                    USER_DEFINED_FUNCTION=true
                    _rename_function $1 d_tmp_$1
                fi

                # The way this logic works is kind of tricky.
                # This function is hooked to the preexec hookable function, and that means that
                # for every command that gets run, this function runs before it. But only certain conditions will you get this far.
                # If you did manage to get this far then you'll save the number you entered, and use that to generate a
                # function that executes the cd - command. Then the function below, named __reset_directory_travel_info, was hooked
                # to the precmd hookable function. That means that it runs every time the prompt gets re-drawn.
                # So basically, in order....
                # 1. preexec generates dynamic function
                # 2. Shell runs dynamic function
                # 3. precmd deletes dynamic function
                D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO=$1
                function $1
                {
                    cd -$D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO
                }
            fi
        fi
    fi

    # Save off user entered command
    USER_LAST_COMMAND=$1
}
add-zsh-hook preexec __directory_navigate_to_user_number_dir


function __reset_directory_travel_info
{
    if (( $D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO != -1 ));
    then
        # Delete the function
        unset -f $D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO

        if [[ "$USER_DEFINED_FUNCTION" = true ]];
        then
            # This works because $D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO is set to the same numeric value
            # as the user function we're trying to preserve.
            _rename_function d_tmp_$D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO $D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO
        fi

        # Reset variables
        D_COMMAND_TEMP_NUMBER_TO_NAVIGATE_TO=-1
        USER_DEFINED_FUNCTION=false
    fi
    
}
add-zsh-hook precmd __reset_directory_travel_info