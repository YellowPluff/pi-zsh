# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} ));
then
    function zle-line-init()
    {
        echoti smkx
    }
    zle -N zle-line-init

    function zle-line-finish()
    {
        echoti rmkx
    }
    zle -N zle-line-finish
fi

__key_BackSpace="${terminfo[kbs]}"
__key_Home="${terminfo[khome]}"
__key_End="${terminfo[kend]}"
__key_Insert="${terminfo[kich1]}"
__key_Delete="${terminfo[kdch1]}"
__key_Up="${terminfo[kcuu1]}"
__key_Down="${terminfo[kcud1]}"
__key_Left="${terminfo[kcub1]}"
__key_Right="${terminfo[kcuf1]}"
__key_PageUp="${terminfo[kpp]}"
__key_PageDown="${terminfo[knp]}"

# Keybind the numpad for PuTTY users
## . Enter
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"

## 0 - 9
bindkey -s "^[Op" "0"
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"

## + - * /
bindkey -s "^[Ol" "+"
bindkey -s "^[OS" "-"
bindkey -s "^[OR" "*"
bindkey -s "^[OQ" "/"