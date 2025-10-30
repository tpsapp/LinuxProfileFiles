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

alias ip='ip -color'

alias hexedit='hexedit --color'

alias sudp='sudo'

alias svim='sudo vim'
alias snano='sudo nano'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias sfind='sudo find / -name'

if [ -f /usr/bin/yay ]; then
    alias inst='yay --needed -S'
    alias uinst='yay -R'
    alias search='yay -Ss'
    alias update='yay --needed -Syu'
    alias ncupd='yay --needed --noconfirm -Syu'
    alias cleanup='yay -Rns $(yay -Qtdq)'
    alias fullclean='cleanup && yay -Scc'
elif [ -f /usr/bin/pacman ]; then
    alias inst='sudo pacman --needed -S'
    alias uinst='sudo pacman -R'
    alias search='pacman -Ss'
    alias update='sudo pacman --needed -Syu'
    alias ncupd='sudo pacman --needed --noconfirm -Syu'
    alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
    alias fullclean='cleanup && sudo pacman -Scc'
elif [ -f /usr/bin/nala ]; then
    alias inst='sudo nala install'
    alias uinst='sudo nala remove'
    alias search='nala search'
    alias update='sudo nala update && sudo nala upgrade'
    alias cleanup='sudo nala autoremove && sudo nala clean'
elif [ -f /usr/bin/apt ]; then
    alias inst='sudo apt install'
    alias uinst='sudo apt remove'
    alias search='apt search'
    alias update='sudo apt update && sudo apt upgrade'
    alias cleanup='sudo apt autoremove && sudo apt clean'
elif [ -f /usr/bin/dnf ]; then
    alias inst='sudo dnf install'
    alias uinst='sudo dnf remove'
    alias search='dnf search'
    alias update='sudo dnf upgrade'
    alias cleanup='sudo dnf clean all'
elif [ -f /usr/bin/yum ]; then
    alias inst='sudo yum install'
    alias uinst='sudo yum remove'
    alias search='yum search'
    alias update='sudo yum upgrade'
    alias cleanup='sudo yum clean all'
fi

if [ -f /usr/bin/pacseek ]; then
    alias search='pacseek -s'
    alias update='pacseek -u'
fi

if [ -f /usr/bin/gnome-terminal ]; then
    alias gnome-terminal='gnome-terminal --window --maximize'
fi
