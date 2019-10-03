#!/bin/bash
# Thomas Miller
# Script to install prereqs for dotfiles to work correctly.
# This ensures TMUX, fish, and Python is installed systemwide
# Also run's ~/.fonts/install.sh, vundle, and ~/.vim/bundle/YouCompleteMe/install.sh

# Color variables
RED='\033[0;31m'
NC='\033[0m' # No Color

DIST=`cat /etc/*-release | grep ^ID= | tr -d ID=\"\"`
case $DIST in
  ("ubuntu"|"debian")
    echo -e "${RED}Distro is Ubuntu, using APT${NC}"

    # if Python
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'python-dev'`" == "not-installed" ]; then
      echo -e "${RED}Installing python-dev${NC}"
      sudo apt-get install python-dev
    else
      echo -e "${RED}python is installed${NC}"
    fi

    # if Fish
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'fish'`" == "not-installed" ]; then
      echo -e "${RED}Installing fish${NC}"
      sudo apt-get install fish
    else
      echo -e "${RED}fish is installed${NC}"
    fi

    # if Tmux
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'tmux'`" == "not-installed" ]; then
      echo -e "${RED}Installings tmux${NC}"
      sudo apt-get install tmux
    else
      echo -e "${RED}tmux is installed${NC}"
    fi

    # if Cmake
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'cmake'`" == "not-installed" ]; then
      echo -e "${RED}Installings cmake${NC}"
      sudo apt-get install cmake
    else
      echo -e "${RED}cmake is installed${NC}"
    fi

    ;;

  ("rhel"|"centos")
    echo -e "${RED}Distro is RHEL, using yum${NC}"

    # if Vim80
    if [ ! -e "/usr/bin/vim80" ]; then
      echo -e "${RED}Downloading and installing Vim80 rpm from my site${NC}"
      wget https://tommydrum.me/vim80-1.0-1.x86_64.rpm
      sudo yum localinstall vim80-1.0-1.x86_64.rpm
    fi

    # if Python
    rpm -q python-devel
    if [ $? -eq 1 ] ; then
      echo -e "${RED}Installing python-devel${NC}"
      sudo yum install python-devel
    else
      echo -e "${RED}python is installed${NC}"
    fi

    # if Fish
    rpm -q fish
    if [ $? -eq 1 ] ; then
      echo -e "${RED}Installing fish${NC}"
      sudo yum install fish
    else
      echo -e "${RED}fish is installed${NC}"
    fi

    # if Tmux
    rpm -q tmux
    if [ $? -eq 1 ] ; then
      echo -e "${RED}Installing tmux${NC}"
      sudo yum install tmux
    else
      echo -e "${RED}tmux is installed${NC}"
    fi

    # if Cmake
    rpm -q cmake
    if [ $? -eq 1 ] ; then
      echo -e "${RED}Installing cmake${NC}"
      sudo yum install cmake
    else
      echo -e "${RED}cmake is installed${NC}"
    fi

    ;;

  *)
    echo -e "${RED}Dotfiles installation is either unable to detect distro or distro is not supported${NC}"
    exit 1
esac

# Moving everything in this dir to ~/
if [ ! "${HOME}" == ${PWD} ]; then
  echo -e "${RED}Installing dotfiles into homedir${NC}"
  shopt -s dotglob
  mv * ~/.
  shopt -u dotglob
fi

# .fonts installation
echo -e "${RED}Running font installation script${NC}"
~/.fonts/install.sh

# vim80 alias installation and setting AND vundle install
echo -e "${RED}Running vundle install (silently)${NC}"
if [ -e "/usr/bin/vim80" ]; then
  echo "alias vim=vim80" >> ~/.zshextras
  echo "alias vi=vim80" >> ~/.zshextras
  /usr/bin/vim80 +PluginInstall +qall
else
  vim +PluginInstall +qall
fi

# Vundle installation


# YouComleteMe Installation
echo -e "${RED}Compiling YouCompleteMe ycmd${NC}"
sh ~/.vim/bundle/YouCompleteMe/install.sh

# oh-my-fish installation
echo -e "${RED}Installing oh-my-fish${NC}"
curl -L https://get.oh-my.fish | fish
