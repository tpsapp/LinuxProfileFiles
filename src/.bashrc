# Thomas Sapp's .bashrc

case $- in
    *i*) ;;
      *) return;;
esac

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

source <(op completion bash)

FG_BLACK='\e[0;30m'
FG_BLUE='\e[0;34m'
FG_GREEN='\e[0;32m'
FG_CYAN='\e[0;36m'
FG_RED='\e[0;31m'
FG_PURPLE='\e[0;35m'
FG_BROWN='\e[0;33m'
FG_LIGHTGRAY='\e[0;37m'
FG_DARKGRAY='\e[1;30m'
FG_LIGHTBLUE='\e[1;34m'
FG_LIGHTGREEN='\e[1;32m'
FG_LIGHTCYAN='\e[1;36m'
FG_LIGHTRED='\e[1;31m'
FG_LIGHTPURPLE='\e[1;35m'
FG_YELLOW='\e[1;33m'
FG_WHITE='\e[1;37m'
RESET_COLOR='\e[0m'


shopt -s histappend
shopt -s checkwinsize

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

HISTCONTROL=ignoreboth
HISTSIZE=-1
HISTFILESIZE=-1
HISTTIMEFORMAT="%m-%d-%Y %T "
HISTIGNORE="&:??:[ ]*:clear:exit:logout"

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	    color_prompt=yes
    else
	    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1="\[$FG_BLUE\][\[$FG_YELLOW\] \u@\h \[$FG_BLUE\]] \[$FG_YELLOW\]\w\$\[$RESET_COLOR\] "
else
    PS1='[ \u@\h ] \w\$ '
fi

unset color_prompt force_color_prompt

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export EDITOR=nano
export LS_COLORS=$LS_COLORS:"*.wmv=01;35":"*.wma=01;35":"*.flv=01;35":"*.m4a=01;35"
