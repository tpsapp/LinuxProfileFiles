# Thomas Sapp's .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

case $- in
    *i*) if [ -f /usr/share/blesh/ble.sh ]; then source /usr/share/blesh/ble.sh; fi;;
      *) return;;
esac

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

if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

if [ -f ~/.local/bin/op ]; then
    source <(op completion bash)
fi

if [ -f /usr/share/doc/find-the-command/ftc.bash ]; then
    source /usr/share/doc/find-the-command/ftc.bash noprompt
fi

if [ -f /home/tpsapp/.local/share/emsdk/emsdk_env.sh ]; then
    source "/home/tpsapp/.local/share/emsdk/emsdk_env.sh"
fi

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
    PS1="\[$FG_BLUE\][\[$FG_YELLOW\] \u\[$FG_BLUE\]@\[$FG_YELLOW\]\h \[$FG_BLUE\]] \[$FG_YELLOW\]\w\$\[$RESET_COLOR\] "
else
    PS1='[ \u@\h ] \w\$ '
fi

unset color_prompt force_color_prompt

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export EDITOR=vim
export LS_COLORS=$LS_COLORS:"*.wmv=01;35":"*.wma=01;35":"*.flv=01;35":"*.m4a=01;35"
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

if [ -f /usr/bin/starship ]; then
    eval "$(starship init bash)"
fi

echo -e "$FG_BLUE***********************************************************"
echo -e "$FG_BLUE*                                                         *"
echo -e "$FG_BLUE* $FG_GREEN Here are some helpful aliases$FG_BLUE                          *"
echo -e "$FG_BLUE*                                                         *"
echo -e "$FG_BLUE* $FG_GREEN svim = Start VIM with sudo$FG_BLUE                             *"
echo -e "$FG_BLUE* $FG_GREEN snano = Start Nano with sudo$FG_BLUE                           *"
echo -e "$FG_BLUE* $FG_GREEN sfind = Find files recursively in / using a filename$FG_BLUE   *"
echo -e "$FG_BLUE* $FG_GREEN inst = Install a program$FG_BLUE                               *"
echo -e "$FG_BLUE* $FG_GREEN uinst = Uninstall a program$FG_BLUE                            *"
echo -e "$FG_BLUE* $FG_GREEN search = Search for a program$FG_BLUE                          *"
echo -e "$FG_BLUE* $FG_GREEN update = Update the system$FG_BLUE                             *"
echo -e "$FG_BLUE* $FG_GREEN cleanup = Clean up the package cache$FG_BLUE                   *"
echo -e "$FG_BLUE*                                                         *"
echo -e "$FG_BLUE***********************************************************"
