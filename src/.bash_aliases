# Global Aliases

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dir_colors && eval "$(dircolors -b ~/.dir_colors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias cls='clear'
alias dir='ls'

alias sudp='sudo'

alias svim='sudo vim'
alias snano='sudo nano'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias sfind='sudo find / -name'

# Ubuntu specific aliases

# alias apt='nala'
# alias inst='sudo apt install'
# alias search='apt search'
# alias update='sudo apt update && sudo apt upgrade'

# Arch specific aliases

alias inst='sudo pacman --needed -S'
# alias inst='yay --needed -S'
# alias search='pacman -Ss'
alias search='yay -Ss'
alias update='yay -Syu'

# GNOME specific aliases
alias gnome-terminal='gnome-terminal --window --maximize'
