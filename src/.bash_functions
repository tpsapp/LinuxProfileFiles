extract () {
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
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

netinfo ()
{
    echo "--------------- Network Information ---------------"
    echo "Wi-Fi:"
    echo -n "IPv4: "
    /sbin/ifconfig wlan0 | awk /'inet / {print $2}'
    echo -n "IPv6: "
    /sbin/ifconfig wlan0 | awk /'inet6 / {print $2}'
    echo -n "Broadcast: "
    /sbin/ifconfig wlan0 | awk /'broadcast/ {print $2}'
    echo -n "Netmask: "
    /sbin/ifconfig wlan0 | awk /'inet / {print $4}'
    echo -n "MAC: "
    /sbin/ifconfig wlan0 | awk /'ether/ {print $2}'
    echo ""
    echo "Ethernet:"
    echo -n "IPv4: "
    /sbin/ifconfig eno0 | awk /'inet / {print $2}'
    echo -n "IPv6: "
    /sbin/ifconfig eno0 | awk /'inet6 / {print $2}'
    echo -n "Broadcast: "
    /sbin/ifconfig eno0 | awk /'broadcast/ {print $2}'
    echo -n "Netmask: "
    /sbin/ifconfig eno0 | awk /'inet / {print $4}'
    echo -n "MAC: "
    /sbin/ifconfig eno0 | awk /'ether/ {print $2}'
    echo ""
    myip=`lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g' `
    echo "${myip}"
    echo "---------------------------------------------------"
}