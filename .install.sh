#!/bin/bash
# Thomas Miller
# Script to install prereqs for dotfiles to work correctly.
# This ensures TMUX, fish, and Python is installed systemwide
# Also run's vundle and ~/.vim/bundle/YouCompleteMe/install.sh

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

  ("rhel"|"centos"|"fedora")
    echo -e "${RED}Distro is RHEL/Fedora, checking for package manager${NC}"

    # Determine the package manager (dnf or rpm-ostree)
    if command -v rpm-ostree &>/dev/null; then
        PKG_MANAGER="rpm-ostree install"
        BATCH_INSTALL=true
    else
        PKG_MANAGER="sudo dnf install"
        BATCH_INSTALL=false
    fi

    # Check and prepare list of packages to install
    declare -a packages_to_install
    if ! rpm -q vim &>/dev/null; then
        packages_to_install+=("vim")
    fi
    if ! rpm -q python-devel &>/dev/null; then
        packages_to_install+=("python-devel")
    fi
    if ! rpm -q fish &>/dev/null; then
        packages_to_install+=("fish")
    fi
    if ! rpm -q tmux &>/dev/null; then
        packages_to_install+=("tmux")
    fi
    if ! rpm -q cmake &>/dev/null; then
        packages_to_install+=("cmake")
    fi

    # Batch install if applicable
    if [ "${#packages_to_install[@]}" -ne 0 ]; then
        if [ "$BATCH_INSTALL" = true ]; then
            echo -e "${RED}Installing packages with rpm-ostree${NC}"
            $PKG_MANAGER "${packages_to_install[@]}"
        else
            for pkg in "${packages_to_install[@]}"; do
                echo -e "${RED}Installing $pkg${NC}"
                $PKG_MANAGER $pkg
            done
        fi
    else
        echo -e "${RED}All necessary packages are installed${NC}"
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

# Vundle install
echo -e "${RED}Running vundle install (silently)${NC}"
vim +PluginInstall +qall

# YouComleteMe Installation
echo -e "${RED}Compiling YouCompleteMe ycmd${NC}"
python3 ~/.vim/bundle/YouCompleteMe/install.py

# oh-my-fish installation
echo -e "${RED}Installing oh-my-fish${NC}"
curl -L https://get.oh-my.fish | fish

# Install bobthefish theme using fish shell
echo -e "${RED}Setting up bobthefish theme${NC}"
fish -c "omf install bobthefish"

# Change the default shell to fish
if command -v fish &>/dev/null; then
    echo -e "${RED}Changing the default shell to fish${NC}"
    chsh -s "$(command -v fish)"
else
    echo -e "${RED}Fish shell is not installed, cannot change the default shell${NC}"
fi
