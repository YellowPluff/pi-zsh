# This feature will display the run time of the previous command on the right side of the prompt.
# Options: 1(On) / 0(Off)
(( ! ${+COMMAND_RUN_TIME_ON_OFF} )) &&
COMMAND_RUN_TIME_ON_OFF=1

# If COMMAND_RUN_TIME_ON_OFF is set to 1, this will set the minimum amount of time (in seconds) that needs to pass for the previous command run time to display.
# Options: Any whole number. Unit is seconds.
(( ! ${+COMMAND_RUN_TIME_MINIMUM_TIME_TO_DISPLAY} )) &&
COMMAND_RUN_TIME_MINIMUM_TIME_TO_DISPLAY=2

# If COMMAND_RUN_TIME_ON_OFF is set to 1, this will be the color of the displayed previous command run time.
# Options: black / red / green / yellow / blue / magenta / cyan / white
(( ! ${+COMMAND_RUN_TIME_COLOR} )) &&
COMMAND_RUN_TIME_COLOR="green"

# If COMMAND_RUN_TIME_ON_OFF is set to 1, this will determine the format of the displayed previous command run time.
# Options: 1(0h 0m 0s) / 2(0h:0m:0s) / 3(0:0:0)
(( ! ${+COMMAND_RUN_TIME_FORMAT} )) &&
COMMAND_RUN_TIME_FORMAT=1

# This feature, the 'd' command, will show you the previous N number of most recent directories that you've visited and let you travel between them quickly.
# Default: 10
(( ! ${+USER_DIRECTORY_STACK_SIZE} )) &&
USER_DIRECTORY_STACK_SIZE=10

# This feature will change the behavior of the up-arrow to match any previously typed command that contains text from what is already typed in.
# For example, if you type in "echo" and press the up-arrow, you'll only be shown commands that contain the word "echo"
# Options: 1(On) / 0(Off)
(( ! ${+CASE_MATCH_UP_ARROW_SEARCH} )) &&
CASE_MATCH_UP_ARROW_SEARCH=1

# This feature will change how the up-arrow matches are displayed if you're using the CASE_MATCH_UP_ARROW_SEARCH feature.
# Matched text will be underlined if this is turned on.
# Options: 1(On) / 0(Off)
(( ! ${+CASE_MATCH_UP_ARROW_SEARCH_UNDERLINE} )) &&
CASE_MATCH_UP_ARROW_SEARCH_UNDERLINE=1

# This feature will alert you to an existing alias if you type a command that you have an alias for.
# Options: 1(On) / 0(Off)
(( ! ${+ALIAS_TIP_FEATURE} )) &&
ALIAS_TIP_FEATURE=1

# Set the git information in the prompt to be loaded in the background.
# Options: 1(On) / 0(Off)
(( ! ${+ASYNC_GIT} )) &&
ASYNC_GIT=1

# When a user types "git pull", this feature will look for all local branches that have already been merged
# and clean them up for you. It only deletes branches locally using the '-d' (safe delete) argument.
# Should you need a branch in the future, you can pull it back down from your remote fork.
# Options: 1(On) / 0(Off)
(( ! ${+CLEAN_GIT_BRANCHES_ON_PULL} )) &&
CLEAN_GIT_BRANCHES_ON_PULL=0

# Bind Ctrl + y to quickly move back a directory. This is the fastest way to move back a directory and it happens in-line.
# Options: 1(On) / 0(Off)
(( ! ${+CTRL_Y_DIR_UP} )) &&
CTRL_Y_DIR_UP=1

# Bind Ctrl + u to quickly move forward a directory. This is the fastest way to move forward a directory and it happens in-line.
# Options: 1(On) / 0(Off)
(( ! ${+CTRL_U_DIR_DOWN} )) &&
CTRL_U_DIR_DOWN=1

# Set a custom color theme for the output of commands that support colorized output. This includes eza, ls, and grep.
# Options: Run the command `list_themes`
(( ! ${+LS_OUTPUT_THEME} )) &&
LS_OUTPUT_THEME="None"

# Auto-Suggestions is a feature that suggests commands as you type based on history.
# Note: This will disable CASE_MATCH_UP_ARROW_SEARCH due to incompatibility between the features.
# Options: 1(On) / 0(Off)
(( ! ${+AUTO_SUGGESTION_PLUGIN} )) &&
AUTO_SUGGESTION_PLUGIN=0

# Syntax highlighting is a feature that provides highlighting of commands as they are typed. This helps in reviewing commands before running them, particularly in catching syntax errors.
# Options: 1(On) / 0 (Off)
(( ! ${+SYNTAX_HIGHLIGHTING_PLUGIN} )) &&
SYNTAX_HIGHLIGHTING_PLUGIN=1

# This features creates a local backup of every change made in your ~/zsh/ directory.
# Options: 1(On) / 0 (Off)
(( ! ${+GIT_BACKUP_HOME_ZSH_DIR} )) &&
GIT_BACKUP_HOME_ZSH_DIR=1

# This feature enables sharing a common command history between all active sessions
# Options: 1(On) / 0 (Off)
(( ! ${+SHARED_COMMAND_HISTORY} )) &&
SHARED_COMMAND_HISTORY=1

# This features automatically keeps wcs-zsh up to date for you.
# Options: 1(On) / 0 (Off)
(( ! ${+AUTO_UPDATE_ZSH} )) &&
AUTO_UPDATE_ZSH=1
