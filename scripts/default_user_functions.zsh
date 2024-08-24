alias command_history="$LOCAL_EDITOR $HOME/.zsh_history"

# compress function
# Usage example: compress <directory to compress> <valid output path>
# Easy to use and standardized way to compress a directory.
function compress
{
    if (( $# == 2 )) && [[ -d $1 ]] && [[ -d $2 ]];
    then
        RUNNING_PATH=$PWD
        ABSOLUTE_PATH_TO_COMPRESS=$(cd $1; pwd)
        ABSOLUTE_OUTPUT_PATH=$(cd $2; pwd)
        OUTPUT_FILE_NAME=$(basename $ABSOLUTE_PATH_TO_COMPRESS).tar.gz
        ABSOLUTE_OUTPUT_PATH_FILE_NAME=$ABSOLUTE_OUTPUT_PATH/$OUTPUT_FILE_NAME

        cd $(dirname $ABSOLUTE_PATH_TO_COMPRESS)
        tar -zcvf $ABSOLUTE_OUTPUT_PATH_FILE_NAME $(basename $ABSOLUTE_PATH_TO_COMPRESS)
        cd $RUNNING_PATH

        echo "Compression Complete!"
        echo "COMPRESSED FILE: $ABSOLUTE_OUTPUT_PATH_FILE_NAME"
    else
        echo "Error.."
        echo "USAGE: compress <directory_to_compress> <valid_output_path>"
    fi
}

# decompress function
# Usage example: decompress <file to decompress> <valid output path>
# Easy to use and catch all way to decompress a compressed file.
function decompress
{
    if (( $# == 2 )) && [[ -f $1 ]] && [[ -d $2 ]];
    then
        if command -v -- "realpath" > /dev/null 2>&1;
        then
            # If the command 'realpath' is installed, use it.
            ABSOLUTE_PATH_TO_DECOMPRESS=$(realpath $1)
        else
            # Else get the realpath ourselves
            local our_pwd=$PWD
            cd $(dirname $1)
            local link=$(readlink $(basename $1))
            while [ "$link" ];
            do
                cd $(dirname $link)
                link=$(readlink $(basename $1))
            done
            local realpath=$PWD/$(basename $1)
            cd $our_pwd

            ABSOLUTE_PATH_TO_DECOMPRESS=$realpath
        fi

        ABSOLUTE_OUTPUT_PATH=$(cd $2; pwd)

        case $ABSOLUTE_PATH_TO_DECOMPRESS in
            *.tar.bz2)
                tar xvjf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.tar.gz)
                tar xvzf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.tar.xz)
                tar Jxvf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.bz2)
                bunzip2 $ABSOLUTE_PATH_TO_DECOMPRESS ;;
            *.gz)
                gunzip $ABSOLUTE_PATH_TO_DECOMPRESS ;;
            *.tar|*.tzr)
                tar xvf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.tbz2)
                tar xvjf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.tgz)
                tar xvzf $ABSOLUTE_PATH_TO_DECOMPRESS --directory $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.zip)
                unzip $ABSOLUTE_PATH_TO_DECOMPRESS -d $ABSOLUTE_OUTPUT_PATH
                echo "Decompression Complete!"
                echo "DECOMPRESSED LOCATION: $ABSOLUTE_OUTPUT_PATH"
                ;;
            *.Z)
                uncompress $ABSOLUTE_PATH_TO_DECOMPRESS ;;
            *.7z)
                7z x $ABSOLUTE_PATH_TO_DECOMPRESS ;;
            *)
                echo "The provided file cannot be decompressed. Did you mean to compress it?" ;
                echo "Provided file: $ABSOLUTE_PATH_TO_DECOMPRESS" ;;
        esac
    else
        echo "Error.."
        echo "USAGE: decompress <file_to_decompress> <valid_output_path>"
    fi
}

function list_themes
{
    # Save off the users current theme
    local CURRENT_USER_THEME=$LS_COLORS

    # Display all themes to the user
    for key value in ${(kv)zsh_themes};
    do
        echo "${Color_Off}Theme: $key"
        export LS_COLORS=$value
        command ls -l --color=auto
        echo
    done

    # Set the theme back to the user theme
    export LS_COLORS=$CURRENT_USER_THEME
}

alias bat="command bat --paging=never --style full,header-filesize"

function tldr
{
    # Save the user current path
    local current_path=$PWD

    # Save the lookup-command
    local lookup_command=$1

    # Navigate the user to the top level directory with the pages
    cd $SCRIPT_PATH/external_dependencies/tldr/tlrc/pages.en/

    # Find the file for the command the user is requesting
    local command_file="$(find . -type f -name "$lookup_command.md")"

    # If the user put in a valid command, print it.
    # Else, show an error.
    if [ $command_file ];
    then
        cd $(dirname $command_file) # cd into the directory housing the <command>.md file for cleaner printing.
        bat $(basename $command_file)
        local _return_code=0 # Set return code to 0 for the input icon colorization
    else
        local _error="${BRed}error${Color_Off}: ${BYellow}${UYellow}$lookup_command${Color_Off} page not found."
        echo $_error
        local _return_code=1 # Set return code to 0 for the input icon colorization
    fi

    # Bring the user back to where they were
    cd $current_path

    return $_return_code
}

alias list_options='cat $SCRIPT_PATH/defaults.zsh | grep -P "(^$|^#|[a-zA-Z]*=)"'

function clean_git_branches
{
    # Store user input arguments, if any. The argument '-y' will disable the confirmation
    # message per branch.
    local user_input=$1

    # Verify that the user is inside a git repository
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]];
    then
        # Store the users current branch
        local current_branch=$(git symbolic-ref -q --short HEAD)

        echo " ~~ Cleaning up local branches that have already been merged to ${BYellow}$current_branch${Color_Off}"

        # Make a list of safe branches that we don't want to delete
        local -a safe_branches # On zsh versions < 5.1, you have to declare local arrays explicitly
        safe_branches=( "main" "master" "*" "$current_branch" )

        # Create array of local git branches to cleanup
        local -a git_branches_to_cleanup # On zsh versions < 5.1, you have to declare local arrays explicitly
        git_branches_to_cleanup=( $(git branch --merged $current_branch) )

        for local_branch in ${git_branches_to_cleanup[@]};
        do
            # Check to see if it's a safe branch
            local is_safe_branch=0
            if (( $safe_branches[(Ie)$local_branch] != 0 ));
            then
                is_safe_branch=1
            fi

            # If it's not a safe branch, process it.
            if (( $is_safe_branch == 0 ));
            then
                # If the user passed in -y, auto-delete everything
                if [[ "$user_input" =~ "^-[Yy]$" ]];
                then
                    echo "Cleanup ${BYellow}$local_branch${Color_Off} ? [y/n] - y"
                    git branch -d $local_branch
                # Otherwise, confirm per branch
                else
                    echo -n "Cleanup ${BYellow}$local_branch${Color_Off} ? [y/n] - "
                    read continue_delete
                    if [[ $continue_delete =~ "^[Yy]$" ]];
                    then
                        git branch -d $local_branch
                    fi
                fi
            fi
        done
    fi
}

function git
{
    local user_git_command=$1

    # If the user wants to do a checkout, and they only provided a number
    if [[ "$user_git_command" =~ "[[:blank:]]*checkout[[:blank:]]*" ]] && [[ $2 =~ "^[0-9]+$" ]];
    then
        __do_git_checkout_based_on_jira_id $@
    else
        # Run the git command the user intended
        command git $@
    fi

    # If user flag is on for "git pull", cleanup local git branches
    if [[ "$1" == "pull" ]] && (( $CLEAN_GIT_BRANCHES_ON_PULL == 1 ));
    then
        clean_git_branches -y
    fi
}

alias tetris="$SCRIPT_PATH/tetris.zsh"
