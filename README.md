# Metasploit in Termux
Script to install Metasploit Framework in Termux

Tested on Android 13 aarch64 with root access.
Doesnt work at the moment - no future plans for fixes 
# How to install
```
apt update && apt upgrade && pkg install wget git curl openssh -y && apt install ncurses-utils && wget https://raw.githubusercontent.com/Creeeeger/Metasploit_in_Termux/master/metasploit.sh && chmod +x metasploit.sh && ./metasploit.sh
```
