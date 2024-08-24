# Lets you use the '=' alias to do math in the terminal. Like a mini calculator

if (( $ZSH_MAJOR_VERSION.$ZSH_MINOR_VERSION >= 5.5 ));
then
    # If you're on zsh version 5.5 or newer, you can use the built in zcalc
    autoload -Uz zcalc
else
    # If you're on zsh version older than 5.5, you must use custom zcalc
    function zcalc
    {
        emulate -L zsh
        setopt extendedglob typesetsilent
        zcalc_show_value () {
            if [[ -n $_base ]]
            then
                print -- $(( $_base $1 ))
            elif [[ $1 = *.* ]] || (( _outdigits ))
            then
                if [[ -z $_forms[_outform] || ( $_outform -eq 1 && $1 = *. ) ]]
                then
                    print -- $(( $1 ))
                else
                    printf "$_forms[_outform]\n" $_outdigits $1
                fi
            else
                printf "%d\n" $1
            fi
        }
        local ZCALC_ACTIVE=1 
        local _line ans _base _defbase _forms match mbegin mend
        local psvar _optlist _opt _arg _tmp
        local compcontext="-zcalc-line-" 
        integer _num _outdigits _outform=1 _expression_mode 
        integer _rpn_mode _matched _show_stack _i _n
        integer _max_stack _push
        local -a _expressions stack
        history -ap "${ZDOTDIR:-$HOME}/.zcalc_history"
        _forms=('%2$g' '%.*g' '%.*f' '%.*E' '') 
        local _mathfuncs
        if zmodload -i zsh/mathfunc 2> /dev/null
        then
            zmodload -P _mathfuncs -FL zsh/mathfunc
            _mathfuncs="("${(j.|.)${_mathfuncs##f:}}")" 
        fi
        local -A _userfuncs
        for _line in ${(f)"$(functions -M)"}
        do
            match=(${=_line}) 
            _userfuncs[${match[3]}]=${match[4]} 
        done
        _line= 
        autoload -Uz zmathfuncdef
        if (( ! ${+ZCALCPROMPT} ))
        then
            typeset -g ZCALCPROMPT="%1v> " 
        fi
        float PI E
        (( PI = 4 * atan(1), E = exp(1) ))
        if [[ -f "${ZDOTDIR:-$HOME}/.zcalcrc" ]]
        then
            . "${ZDOTDIR:-$HOME}/.zcalcrc" || return 1
        fi
        while [[ -n $1 && $1 = -(|[#-]*|f|e|r(<->|)) ]]
        do
            _optlist=${1[2,-1]} 
            shift
            [[ $_optlist = (|-) ]] && break
            while [[ -n $_optlist ]]
            do
                _opt=${_optlist[1]} 
                _optlist=${_optlist[2,-1]} 
                case $_opt in
                    ('#') if [[ -n $_optlist ]]
                        then
                            _arg=$_optlist 
                            _optlist= 
                        elif [[ -n $1 ]]
                        then
                            _arg=$1 
                            shift
                        else
                            print -- "-# requires an argument" >&2
                            return 1
                        fi
                        if [[ $_arg != (|\#)[[:digit:]]## ]]
                        then
                            print -- "-# requires a decimal number as an argument" >&2
                            return 1
                        fi
                        _defbase="[#${_arg}]"  ;;
                    (e) (( _expression_mode = 1 )) ;;
                    (r) (( _rpn_mode = 1 ))
                        ZCALC_ACTIVE=rpn 
                        if [[ $_optlist = (#b)(<->)* ]]
                        then
                            (( _show_stack = ${match[1]} ))
                            _optlist=${_optlist[${#match[1]}+1,-2]} 
                        fi ;;
                esac
            done
        done
        if (( _expression_mode ))
        then
            _expressions=("$@") 
            argv=() 
        fi
        for ((_num = 1; _num <= $#; _num++ )) do
            (( argv[$_num] = $argv[$_num] ))
            print "$_num> $argv[$_num]"
        done
        psvar[1]=$_num 
        local _prev_line _cont_prompt
        while (( _expression_mode )) || vared -cehp "${_cont_prompt}${ZCALCPROMPT}" _line
        do
            if (( _expression_mode ))
            then
                (( ${#_expressions} )) || break
                _line=$_expressions[1] 
                shift _expressions
            fi
            if [[ $_line = (|*[^\\])('\\')#'\' ]]
            then
                _prev_line+=$_line[1,-2] 
                _cont_prompt="..." 
                _line= 
                continue
            fi
            _line="$_prev_line$_line" 
            _prev_line= 
            _cont_prompt= 
            if [[ ${#_line//[^\(]} -gt ${#_line//[^\)]} ]]
            then
                _prev_line+=$_line 
                _cont_prompt="..." 
                _line= 
                continue
            fi
            [[ -z $_line ]] && break
            if [[ $_line = (#b)[[:blank:]]#('[#'(\#|)((<->|)(|_|_<->))']')[[:blank:]]#(*) ]]
            then
                if [[ -z $match[6] ]]
                then
                    if [[ -z $match[3] ]]
                    then
                        _defbase= 
                    else
                        _defbase=$match[1] 
                    fi
                    print -s -- $_line
                    print -- $(( ${_defbase} ans ))
                    _line= 
                    continue
                else
                    _base=$match[1] 
                fi
            else
                _base=$_defbase 
            fi
            print -s -- $_line
            _line="${${_line##[[:blank:]]#}%%[[:blank:]]#}" 
            case "$_line" in
                (:(\\|)\!*) eval ${_line##:(\\|)\![[:blank:]]#}
                    _line= 
                    continue ;;
                ((:|)q) return 0 ;;
                ((:|)norm) _outform=1  ;;
                ((:|)sci[[:blank:]]#(#b)(<->)(#B)) _outdigits=$match[1] 
                    _outform=2  ;;
                ((:|)fix[[:blank:]]#(#b)(<->)(#B)) _outdigits=$match[1] 
                    _outform=3  ;;
                ((:|)eng[[:blank:]]#(#b)(<->)(#B)) _outdigits=$match[1] 
                    _outform=4  ;;
                (:raw) _outform=5  ;;
                ((:|)local([[:blank:]]##*|)) eval ${_line##:}
                    _line= 
                    continue ;;
                ((function|:f(unc(tion|)|))[[:blank:]]##(#b)([^[:blank:]]##)(|[[:blank:]]##([^[:blank:]]*))) zmathfuncdef $match[1] $match[3]
                    _userfuncs[$match[1]]=${$(functions -Mm $match[1])[4]} 
                    _line= 
                    continue ;;
                (:*) print "Unrecognised escape"
                    _line= 
                    continue ;;
                (\$[[:IDENT:]]##) _line=${_line##\$} 
                    print -r -- ${(P)_line}
                    _line= 
                    continue ;;
                (*) _line=${${_line##[[:blank:]]##}%%[[:blank:]]##} 
                    if [[ _rpn_mode -ne 0 && $_line != '' ]]
                    then
                        _push=1 
                        _matched=1 
                        case $_line in
                            (\<[[:IDENT:]]##) ans=${(P)${_line##\<}}  ;;
                            (\=|pop|\>[[:IDENT:]]#) if (( ${#stack} < 1 ))
                                then
                                    print -r -- "${_line}: not enough values on stack" >&2
                                    _line= 
                                    continue
                                fi
                                case $_line in
                                    (=) ans=${stack[1]}  ;;
                                    (pop|\>) _push=0 
                                        shift stack ;;
                                    (\>[[:IDENT:]]##) if [[ ${_line##\>} = (_*|stack|ans|PI|E) ]]
                                        then
                                            print "${_line##\>}: reserved variable" >&2
                                            _line= 
                                            continue
                                        fi
                                        local ${_line##\>}
                                        (( ${_line##\>} = ${stack[1]} ))
                                        _push=0 
                                        shift stack ;;
                                    (*) print "BUG in special RPN functions" >&2
                                        _line= 
                                        continue ;;
                                esac ;;
                            (+|-|\^|\||\&|\*|/|\*\*|\>\>|\<\</) if (( ${#stack} < 2 ))
                                then
                                    print -r -- "${_line}: not enough values on stack" >&2
                                    _line= 
                                    continue
                                fi
                                eval "(( ans = \${stack[2]} $_line \${stack[1]} ))"
                                shift 2 stack ;;
                            (ldexp|jn|yn|scalb|xy|\<\>) if (( ${#stack} < 2 ))
                                then
                                    print -r -- "${_line}: not enough values on stack" >&2
                                    _line= 
                                    continue
                                fi
                                if [[ $_line = (xy|\<\>) ]]
                                then
                                    _tmp=${stack[1]} 
                                    stack[1]=${stack[2]} 
                                    stack[2]=$_tmp 
                                    _push=0 
                                else
                                    eval "(( ans = ${_line}(\${stack[2]},\${stack[1]}) ))"
                                    shift 2 stack
                                fi ;;
                            (${~_mathfuncs}) if (( ${#stack} < 1 ))
                                then
                                    print -r -- "${_line}: not enough values on stack" >&2
                                    _line= 
                                    continue
                                fi
                                eval "(( ans = ${_line}(\${stack[1]}) ))"
                                shift stack ;;
                            (${(kj.|.)~_userfuncs}) _n=${_userfuncs[$_line]} 
                                if (( ${#stack} < n_ ))
                                then
                                    print -r -- "${_line}: not enough values ($_n) on stack" >&2
                                    _line= 
                                    continue
                                fi
                                _line+="(" 
                                for ((_i = _n; _i > 0; _i-- )) do
                                    _line+=${stack[_i]} 
                                    (( _i > 1 )) && _line+="," 
                                done
                                _line+=")" 
                                shift $_n stack
                                eval "(( ans = $_line ))" ;;
                            (*) _matched=0  ;;
                        esac
                    else
                        _matched=0 
                    fi
                    if (( ! _matched ))
                    then
                        if ! eval "ans=\$(( $_line ))"
                        then
                            _line= 
                            continue
                        fi
                        [[ -n $ans ]] || continue
                    fi
                    argv[_num++]=$ans 
                    psvar[1]=$_num 
                    (( _push )) && stack=($ans $stack)  ;;
            esac
            if (( _show_stack ))
            then
                (( _max_stack = (_show_stack > ${#stack}) ? ${#stack} : _show_stack ))
                for ((_i = _max_stack; _i > 0; _i-- )) do
                    printf "%3d: " $_i
                    zcalc_show_value ${stack[_i]}
                done
            else
                zcalc_show_value $ans
            fi
            _line= 
        done
        return 0
    }
fi

function __calc_function
{
    zcalc -f -e "$*"
}
aliases[=]='noglob __calc_function'