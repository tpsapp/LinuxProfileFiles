helpmsg () {
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
}

extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

mount-nas () {
    echo Mounting SAPPNAS...
    mkdir -p ~/SAPPNAS
    if [ -f "/home/tpsapp/.sappnas_creds" ]; then
        echo "Mounting NAS with credentials file..."
        sudo mount //sappnas/backup ~/SAPPNAS -o gid=$USER,uid=$USER,credentials=/home/tpsapp/.sappnas_creds
    elif [ $# == 0 ]; then
        echo "No user or password provided for NAS, using admin as user.  Please enter the password below..."
        sudo mount //sappnas/backup ~/SAPPNAS -o gid=$USER,uid=$USER,user=admin
    elif [ $# == 1 ]; then
        echo "No password provided for NAS user $1, please enter it below..."
        sudo mount //sappnas/backup ~/SAPPNAS -o user=$1,gid=$USER,uid=$USER
    else
        sudo mount //sappnas/backup ~/SAPPNAS -o user=$1,gid=$USER,uid=$USER,pass=$2
    fi
}

umount-nas () {
    echo Unmounting nas...
    sudo umount -R ~/SAPPNAS
}
