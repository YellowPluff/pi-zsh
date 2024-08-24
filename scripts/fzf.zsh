# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Sets the default global options when using fzf
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#121212,bg+:#262626
  --color=hl:#52a8ff,hl+:#00bfff,info:#afaf87,marker:#ff00ff
  --color=prompt:#ff8800,spinner:#ff8800,pointer:#87ff00,header:#87afaf
  --color=border:#262626,separator:#8b8b8b,scrollbar:#8b8b8b,preview-border:#8b8b8b
  --color=label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="/ "
  --marker="~" --pointer=">" --separator="─" --scrollbar="│"'

# Sets the preview style for when using keyboard shortcuts CTRL+T (file) and ALT+C (directory)
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:100 {}"'
export FZF_ALT_C_OPTS='--preview "eza -lA --no-user --octal-permissions --no-permissions --color=always {}"'

# Sets the preview style for when using **<TAB>
# The preview set is specific to the command
# If the command is not explicity accounted for, the preview set is specific to the file type.
function _fzf_comprun
{
    local command=$1
    shift

    case "$command" in
        cd)           fzf --preview "eza -lA --no-user --octal-permissions --no-permissions --color=always {}"                "$@" ;;
        export|unset) fzf --preview "eval 'echo \$'{}"                                                                        "$@" ;;
        ssh)          fzf --preview 'dig {}'                                                                                  "$@" ;;
        *)            fzf --preview "zsh -c $(functions _set_preview_based_on_file_type); _set_preview_based_on_file_type {}" "$@" ;;
    esac
}

# Sets the preview style depending on the file type
# You could also add specific files. If you wanted a specific preview for a specific file, that would go here.
function _set_preview_based_on_file_type
{
    case "$1" in
      # This is here for example
      # *.txt) bat --color=always --style=numbers --line-range=:100 $1 ;;
      *)
          # Catch all case.
          if [[ -d "$1" ]];
          then
              # If you're a directory, use eza.
              eza -lA --no-user --octal-permissions --no-permissions --color=always $1
          else
              # If you're a file, use bat.
              bat --color=always --style=numbers --line-range=:100 $1
          fi
          ;;
    esac
}





# This function, ran by keyboard shortcut <ctrl + space>, is a function that toggles fzf completion.
# It's a generic function that allows us to do custom things with fzf.
# For example, if there is no user buffer, it'll let the user select a script to run.
# If none of the conditions for custom logic are met, the default fzf completion is triggered. This is the same as **<TAB>
# Basically, this is a catch all function for fzf logic.
function __run_fzf_completion()
{
    # Remove all trailing whitespaces from the LBUFFER
    LBUFFER="$(echo $LBUFFER | sed -r 's/[[:blank:]]*$//g')"

    # Array of buffer tokens split by the space
    local -a user_buffer_tokens # On zsh versions < 5.1, you have to declare local arrays explicitly
    user_buffer_tokens=(${(z)LBUFFER})

    # Take the LBUFFER and expand it if it's an alias.
    local user_buffer_expanded=$LBUFFER
    [[ "$aliases[$LBUFFER]" != "" ]] && user_buffer_expanded="$aliases[$LBUFFER]"

    if [[ $user_buffer_expanded == "" ]];
    then
        # If the LBUFFER is empty, as in the user hasn't put in any text, use fzf to select
        # something to run, like a binary or a script.
        __run_script_using_fzf
    elif [[ $user_buffer_expanded =~ "^[[:blank:]]*git checkout[[:blank:]]*$" ]];
    then
        # If the buffer is "git checkout", use fzf to select a branch for checking out
        __run_git_branch_using_fzf
    else
        # Else, there is no custom logic, so continue to default fzf completion.
        __run_default_fzf_completion
    fi

    # If using auto suggestions, fetch a solution given the updated buffer
    (( $AUTO_SUGGESTION_PLUGIN == 1 )) && _zsh_autosuggest_fetch
}
zle -N __run_fzf_completion
bindkey "^ " __run_fzf_completion

function __run_script_using_fzf
{
    # Run fzf, reading the input from the controlling terminal for the current process
    local completion=$(fzf < /dev/tty)

    # Verify that the user made a selection
    if [[ $completion != "" ]];
    then
        # Replace the user buffer with the selection, accounting for escaped characters
        LBUFFER="./${(q-)completion}"
    fi
}

function __run_git_branch_using_fzf
{
    # Verify that the user is inside a git repository
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]];
    then
        # Prompt user to pick a branch to check out (Filtered out current branch)
        local branch_completion=$(git branch -a | grep -v "^\*" | fzf)

        # Verify that the user made a branch selection
        if [[ $branch_completion != "" ]];
        then
            # Strip all beginning whitespaces from the branch selection
            branch_completion="$(echo $branch_completion | sed -r 's/^[[:blank:]]*//g')"

            # Set the users buffer
            LBUFFER="$LBUFFER ${(q-)branch_completion}"
        fi
    else
        # Not inside a git repo, so just run their 'git checkout' and let git do the error printing
        zle accept-line
    fi
}

function __run_default_fzf_completion
{
    # Define the fzf completion trigger (can be custom / user defined)
    local fzf_completion_trigger=${FZF_COMPLETION_TRIGGER-'**'}

    # Get the tail of the LBUFFER in the number of characters of the fzf completion trigger
    # If your completion trigger is 2 character (**), this grabs the last 2 characters of the LBUFFER
    local tail_of_cmd=${LBUFFER:$(( ${#LBUFFER} - ${#fzf_completion_trigger} ))}

    # If the LBUFFER does not end with the fzf completion trigger (**), add it
    if [[ "$tail_of_cmd" != "$fzf_completion_trigger" ]];
    then
        local last_buffer_token=$user_buffer_tokens[-1]

        # If the last LBUFFER token is a directory, assume the user wants to do fzf completion at that directory
        if [[ -d $last_buffer_token ]];
        then
            LBUFFER="$LBUFFER$fzf_completion_trigger"
        else
            # Otherwise it's a file, and therefore end of the line, so assume the user wants to fzf complete on something else
            LBUFFER="$LBUFFER $fzf_completion_trigger"
        fi
    fi

    fzf-completion

    # If the user exits fzf without making a selection, revert to the previous buffer
    local tail_of_cmd=${LBUFFER:$(( ${#LBUFFER} - ${#fzf_completion_trigger} ))}
    if [[ "$tail_of_cmd" == "$fzf_completion_trigger" ]];
    then
        LBUFFER=$user_buffer_tokens
    fi
}
