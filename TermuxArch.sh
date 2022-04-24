#!/bin/bash


#Fix \n bash problem
shopt -s xpg_echo


#Spinner
spinner() {
    local pid=$1
    local delay=0.20
    # shellcheck disable=SC1003
    local spinstr='|/-\'
 
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
 
    printf "    \b\b\b\b"
}


#Functions
install_term_utils() {
    clear
    echo -n "Installing Termux X11 and Utility ... "
    yes | pkg install x11-repo > log.txt 2>&1
    yes | pkg update > log.txt 2>&1
    yes | pkg upgrade > log.txt 2>&1
    yes | pkg install tigervnc proot-distro > log.txt 2>&1
}

install_arch(){
    echo -n "Installing Arch... "
    proot-distro install archlinux > log.txt 2>&1
    rm log.txt
}

arch_utils(){
    echo -n "Installing Xorg,Xfce4 and blackarch repositories (This will take some time)... \n"
    echo -n "Upgrading System... \n"
    proot-distro login archlinux -- pacman -Syuu --noconfirm > /dev/null 2>&1
    echo -n "Installing xorg and xfce4... \n"
    proot-distro login archlinux -- pacman -S --noconfirm xorg xfce4 > /dev/null 2>&1
    echo -n "Installing Blackarch repositories..."
    proot-distro login archlinux -- curl -O https://blackarch.org/strap.sh > /dev/null 2>&1
    proot-distro login archlinux -- chmod +x strap.sh
    proot-distro login archlinux -- ./strap.sh > /dev/null 2>&1
    proot-distro login archlinux -- rm strap.sh
}

scripts(){
    echo "Creating automatization scripts... "
    echo 'proot-distro login archlinux' > /data/data/com.termux/files/usr/bin/arch
    chmod +x /data/data/com.termux/files/usr/bin/arch
    proot-distro login archlinux -- curl -O https://raw.githubusercontent.com/XChaosSaMa/TermuxArch/main/desktop > /dev/null 2>&1
    proot-distro login archlinux -- mv desktop /usr/bin/desktop
    proot-distro login archlinux -- chmod +x /usr/bin/desktop
}


#Adding Spinner
(install_term_utils) &
spinner $! && echo "Done ✔"

(install_arch) &
spinner $! && echo "Arch is now installed ✔"

(arch_utils) &
spinner $! && echo "Finished installing Xorg,Xfce4 and Blackarch repositories ✔"

(scripts) &
spinner $! && echo "Done ✔"

clear
proot-distro login archlinux -- vncserver -listen tcp
proot-distro login archlinux -- xhost +localhost && xhost +

sleep 3
clear


echo "***************************************************"
echo "*                                                 *"
echo "*                  FINISHED!                      *"
echo "*                                                 *"
echo "* You can use:                                    *"
echo "* (arch) in Termux to login to arch               *"
echo "* (desktop) in Arch to prepare the xcfe4-session  *"
echo "*                                                 *"
echo "* In VNCViewer app:                               *"
echo "* Configure session to localhost:1                *"
echo "* And insert the password you set                 *"
echo "***************************************************"