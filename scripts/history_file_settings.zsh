# Set the history file path
HISTFILE=$HOME/.zsh_history

# Set how many lines of history to keep in memory
HISTSIZE=256

# Set how many lines of history to keep in the history file
SAVEHIST=100000

if (( $SHARED_COMMAND_HISTORY == 1 ));
then
    # Share history between sessions. (SHOULD BE DISABLED IF INC_APPEND_HISTORY IS ENABLED)
    setopt SHARE_HISTORY
else
    # Write to the history file immediately, not when the shell exits. (SHOULD BE DISABLED IF SHARE_HISTORY IS ENABLED)
    setopt INC_APPEND_HISTORY
fi

setopt HIST_FIND_NO_DUPS        # Do not display a line previously found.
setopt HIST_IGNORE_ALL_DUPS     # Delete old recorded entry if new entry is a duplicate.
setopt HIST_REDUCE_BLANKS       # Remove superfluous blanks before recording entry.
# setopt EXTENDED_HISTORY       # Write the history file in the ":start:elapsed;command" format.
# setopt BANG_HIST              # Treat the '!' character specially during expansion.
# setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
# setopt HIST_IGNORE_DUPS       # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space.
# setopt HIST_VERIFY            # Don't execute immediately upon history expansion.
# setopt HIST_BEEP              # Beep when accessing non-existent history.

# Enable matching search of history using up/down arrow keys.
# Match commands that start with what has already been entered into the prompt.
# The up arrow searches backward
# The down arrow searches forward
if (( $CASE_MATCH_UP_ARROW_SEARCH == 1 ));
then
    source $SCRIPT_PATH/external_dependencies/zsh-history-substring-search.zsh
    bindkey "$__key_Up" history-substring-search-up
    bindkey "$__key_Down" history-substring-search-down
fi

