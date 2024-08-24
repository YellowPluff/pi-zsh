# Override the SHELL environment variable while wcs-zsh is running
export SHELL=$(which zsh)

# Global variables for holding running zsh version
ZSH_MAJOR_VERSION=$(echo $ZSH_VERSION | cut -d. -f1)
ZSH_MINOR_VERSION=$(echo $ZSH_VERSION | cut -d. -f2)
ZSH_BRANCH_VERSION=$(echo $ZSH_VERSION | cut -d. -f3)

# This sets the default permissions on new files / directories
# Files are RW-RW-R--
# Directories are RWXRWXR-X
umask 002

# This is the path of the actively running script.
# For example... If your .zshrc calls your dev version of main.zsh then you'll get your dev version of defaults.zsh
# This is necessary for development. Devs should change their .zshrc to source their local dev version of main.zsh to test changes
SCRIPT_PATH=${0:a:h}

# Set local editor. Mostly used for the "command_history" command
export LOCAL_EDITOR="nano"

# Turn on application mode for zle and set keybind variables
source $SCRIPT_PATH/key_bindings.zsh

# Hooking a function is a feature of ZSH that attaches a custom function to
# an existing hookable function. When the hookable function is executed so is the custom
# function that was hooked to it.

# While you can modify hookable functions directly, it's cleaner to seperate logic into
# custom specific functions then add the custom function as a hook to the hookable function.

# For more information, including the full list of hookable functions, see
# https://stephencharlesweiss.com/zsh-hooks

# Also, autoload tells ZSH to look for a file in $FPATH/$fpath containing a function definition,
# instead of a file in $PATH/$path containing an executable script or binary.
# -U flag, alias expansion is suppressed when the function is loaded.
# -z flag, mark the function to be autoloaded using the zsh style.
autoload -Uz add-zsh-hook

# Required so *NIX knows where to find commonly used commands
source $SCRIPT_PATH/path.zsh

# This sets the default values for values that users can configure in their zshrc
source $SCRIPT_PATH/defaults.zsh

# This sets all the color variables available for use
# Also creates the zsh theme associative array, and sets user theme
source $SCRIPT_PATH/colors.zsh

# Source custom defined functions intended to be used by zsh processing
source $SCRIPT_PATH/utility_functions.zsh

# Enable the alias tip feature
source $SCRIPT_PATH/alias_tip.zsh

# Enable the right prompt previous command run time
source $SCRIPT_PATH/command_run_time.zsh

# Enable the dynamic terminal title
source $SCRIPT_PATH/terminal_title.zsh

# Enable the in-line calculator.
source $SCRIPT_PATH/in_line_calc.zsh

# Set the user defined prompt
source $HOME/zsh/prompt.zsh
# Save off user defined prompt for use in the alert system
USER_PROMPT=$PROMPT

# If it doesn't yet exist from a parent process,
# Initialize the PROMPT_ALERT variable
(( ! ${+PROMPT_ALERT} )) && export PROMPT_ALERT=""

# Retrieve git information for prompt
if (( $ASYNC_GIT == 1 ));
then
    source $SCRIPT_PATH/async_git.zsh
else
    source $SCRIPT_PATH/git.zsh
fi

# Enable quick directory navigation using the 'd' command.
source $SCRIPT_PATH/d_command.zsh

# Enable file path naviagtion using ctrl+y and ctrl+u
source $SCRIPT_PATH/up_down_command.zsh

# Keybind Delete, Home, and End keys
bindkey "$__key_Delete" delete-char
bindkey "$__key_Home" beginning-of-line
bindkey "$__key_End" end-of-line

# Setup the ZSH completion system
source $SCRIPT_PATH/zsh_completion.zsh

# Aliases are parsed before functions, so if you have alias foo and function foo then
# foo would return the alias. This is important when trying to overload an alias or
# when you have an alias and function of the same name.

# Source custom defined functions intended to be used by users
source $SCRIPT_PATH/default_user_functions.zsh

# Source user defined aliases
source $HOME/zsh/aliases.zsh

# Source user defined functions
source $HOME/zsh/functions.zsh

# Setup automatic sourcing of prompt / aliases / functions files
source $SCRIPT_PATH/auto_sourcer.zsh

# Configure FZF
source $SCRIPT_PATH/fzf.zsh

if (( $AUTO_SUGGESTION_PLUGIN == 1 ));
then
    source $SCRIPT_PATH/external_dependencies/zsh-autosuggestions.zsh
fi

######### DO NOT MODIFY BELOW THIS LINE #########
# Syntax Highlighting and zsh-history-substring-search (history_file_settings.zsh)
# need to go last.
# The reasoning is syntax highlighting works by hooking into the Zsh Line Editor (ZLE)
# and computing syntax highlighting for the command-line buffer as it stands at the time z-sy-h's hook is invoked.
# In zsh 5.2 and older, zsh-syntax-highlighting.zsh hooks into ZLE by wrapping ZLE widgets. It must be sourced after all
# custom widgets have been created (i.e., after all zle -N calls and after running compinit) in order to be able to wrap all
# of them. Widgets created after z-sy-h is sourced will work, but will not update the syntax highlighting.
#
# Then, zsh-history-substring-search either taps into the syntax highlighter or defines it's own basic one. But it needs to
# know if you're using syntax highlighting.
if (( $SYNTAX_HIGHLIGHTING_PLUGIN == 1 ));
then
    source $SCRIPT_PATH/external_dependencies/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fi

# Setup the history file
# Note: This must be done after syntax highlighting.
source $SCRIPT_PATH/history_file_settings.zsh

