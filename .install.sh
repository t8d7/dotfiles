#!/bin/bash
# Thomas Miller
# Script to install prereqs for dotfiles to work correctly.
# This ensures TMUX, ZSH, and Python is installed systemwide
# Also run's ~/.fonts/install.sh, vundle, and ~/.vim/bundle/YouCompleteMe/install.sh
DIST=`cat /etc/*-release | grep ^ID= | tr -d ID=\"\"`
case $DIST in
  "ubuntu")
    echo Distro is Ubuntu, using APT

    # if Python
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'python-dev'`" == "not-installed" ]; then
      echo Installing python-dev
      sudo apt-get install python-dev
    else
      echo python is installed
    fi

    # if Zsh
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'zsh'`" == "not-installed" ]; then
      echo Installing zsh
      sudo apt-get install zsh
    else
      echo zsh is installed
    fi

    # if Tmux
    if [ "`/usr/bin/dpkg-query --show --showformat='${db:Status-Status}\n' 'tmux'`" == "not-installed" ]; then
      echo Installings tmux
      sudo apt-get install tmux
    else
      echo tmux is installed
    fi
    ;;

  "rhel")
    echo Distro is RHEL, using yum

    # if Python
    if [ `rpm -q python-dev 1&>/dev/null` ]; then
      echo Installing python-devel
      sudo yum install python-devel
    else
      echo python is installed
    fi

    # if Zsh
    if [ `rpm -q zsh 1&>/dev/null` ]; then
      echo Installing zsh
      sudo yum install zsh
    else
      echo zsh is installed
    fi

    # if Tmux
    if [ `rpm -q tmux 1&>/dev/null` ]; then
      echo Installing tmux
      sudo yum install tmux
    else
      echo tmux is installed
    fi
    ;;

  *)
    echo "Dotfiles installation is either unable to detect distro or distro is not supported"
    exit 1
esac

# Moving everything in this dir to ~/
if [ ! "${HOME}" == ${PWD} ]; then
  echo Installing dotfiles into homedir
  shopt -s dotglob
  mv * ~/.
  shopt -u dotglob
fi

echo Running font installation script
~/.fonts/install.sh

echo Running vundle install (silently)
vim +PluginInstall +qall &>/dev/null

echo Compiling YouCompleteMe ycmd
~/.vim/bundle/YouComleteMe/install.sh

