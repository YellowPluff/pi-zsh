# ZSH completion system docs: https://zsh.sourceforge.io/Doc/Release/Completion-System.html

# Initialize the ZSH builtin completion system.
autoload -Uz compinit

# Completion specific setup
zstyle ':completion:*' completer _complete _expand _ignored _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[._-]=** r:|=**' 'l:|=* r:|=*'

compinit -u