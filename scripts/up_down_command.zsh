#
# "up" and "down" and meant to be called directly by the user
# __up_dir is for the keybord shortcut ctrl + y
# __down_dir is for the keyboard shortcut ctrl + u
#

# Up function
# Usage example: up 3
# Would execute cd ../../..
function up
{
    local times=$1
    
    if (( $# == 0 ));
    then
        times=1
    fi

    while [ "$times" -gt "0" ];
    do
        cd ..
        times=$(($times - 1))
    done
}

# Down function
# Usage example: down 3
# Undoes the up function
function down
{
    local times=$1

    if (( $# == 0 ));
    then
        times=1
    fi

    while [ "$times" -gt "0" ];
    do
        popd
        times=$(($times - 1))
    done
}


function __up_dir
{
    up
    if (( $ASYNC_GIT == 1 ));
    then
        __start_git_async_job
    else
        __update_git_information
    fi
    zle reset-prompt
}

function __down_dir
{
    # If there is a directory on the directory stack...
    if [[ $dirstack ]];
    then
        # If the directory to navigate down to is within the current directory...
        if [[ "$dirstack[1]" =~ "$PWD*" ]];
        then
            down
            if (( $ASYNC_GIT == 1 )); then
                __start_git_async_job
            else
                __update_git_information
            fi
            zle reset-prompt
        fi
    fi
}

if (( $CTRL_Y_DIR_UP == 1 ));
then
    # Register the function __up_dir as a ZLE widget
    # Keybind ctrl + y to the widget __up_dir
    zle -N __up_dir
    bindkey "^y" __up_dir
fi

if (( $CTRL_U_DIR_DOWN == 1 ));
then
    # Register the function __down_dir as a ZLE widget
    # Keybind ctrl + u to the widget __down_dir
    zle -N __down_dir
    bindkey "^u" __down_dir
fi