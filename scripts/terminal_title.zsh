# This logic sets the title of the terminal.
# If the function is called from preexec then it'll set the title to the running command.
# If the function is called from precmd then it'll set the title to the server name.
function __set_terminal_title
{
    if [ $1 ];
    then
        local current_time=$(TZ=America/New_York date +"%H:%M")
        echo -ne "\033]0;$HOST: [$current_time] $1\007"
    else
        echo -ne "\033]0;$HOST\007"
    fi
}
add-zsh-hook preexec __set_terminal_title
add-zsh-hook precmd __set_terminal_title