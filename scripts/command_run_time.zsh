# This logic captures the time when a user runs a command
function __start_command_timer
{
    command_run_time_timer=$(date +%s)
}
add-zsh-hook preexec __start_command_timer

# This logic captures the time when a user command finishes, then sets
# the right prompt with the run time.
function __set_runtime_right_prompt
{
    if [ $command_run_time_timer ];
    then
        local now=$(date +%s)
        local elapsed=$((now-command_run_time_timer))
        
        local hours=$(( elapsed / 60 / 60 % 24 ))
        local minutes=$(( elapsed / 60 % 60 ))
        local seconds=$(( elapsed % 60 ))

        if (( $COMMAND_RUN_TIME_ON_OFF == 1 ));
        then
            if (( $elapsed >= $COMMAND_RUN_TIME_MINIMUM_TIME_TO_DISPLAY ));
            then
                if (( $COMMAND_RUN_TIME_FORMAT == 2 ));
                then
                    export RPROMPT="%F{$COMMAND_RUN_TIME_COLOR}%B$COMMAND_RUN_TIME_PRE_FIXED_WORD ${hours}h:${minutes}m:${seconds}s%b%f"
                elif (( $COMMAND_RUN_TIME_FORMAT == 3 ));
                then
                    export RPROMPT="%F{$COMMAND_RUN_TIME_COLOR}%B$COMMAND_RUN_TIME_PRE_FIXED_WORD ${hours}:${minutes}:${seconds}%b%f"
                else
                    export RPROMPT="%F{$COMMAND_RUN_TIME_COLOR}%B$COMMAND_RUN_TIME_PRE_FIXED_WORD ${hours}h ${minutes}m ${seconds}s%b%f"
                fi
            else
                export RPROMPT=""
            fi
        else
            export RPROMPT=""
        fi
        
        unset command_run_time_timer
    fi
}
add-zsh-hook precmd __set_runtime_right_prompt
