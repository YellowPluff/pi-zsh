# Turn on prompt substitution
setopt PROMPT_SUBST

# Load Version Control System Information
autoload -Uz vcs_info

# Format the GIT_INFO_MESSAGE variable
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats $'%B%F{'$GIT_REPO_BRANCH_NAME_COLOR'}%b%f %F{red}%u%f%F{green}%c%f%F{red}%a%f%%b'

function __update_git_information
{
    # The VCS code that comes with ZSH is broken when using our custom git function.
    # This problem only affects WCS-ZSH when ASYNC_GIT is turned off (set to 0).
    # Trial and error proved that the simplest solution is to temporarily undo our custom
    # git function. I did this by re-naming the function, then re-naming it back.
    _rename_function git _temp_git
    vcs_info
    _rename_function _temp_git git

    GIT_INFO_MESSAGE=$vcs_info_msg_0_
}
add-zsh-hook precmd __update_git_information