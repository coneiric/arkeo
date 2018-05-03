# Copyright (c) 2015-2018, The Kovri I2P Router Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#!/bin/bash

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root

DEFAULT_USER="nomado"

# Ensure host $DEFAULT_USER has same UID as docker container user
# - needed for shared files between containers and host
! id $DEFAULT_USER && useradd -m -s /bin/bash --uid 1000 -G docker $DEFAULT_USER
cp -aT /etc/skel/ /home/$DEFAULT_USER
chmod 700 /home/$DEFAULT_USER

sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf

systemctl enable pacman-init.service choose-mirror.service
systemctl set-default multi-user.target
systemctl poweroff -i

# Read boolean handler
# $1 - message
# $2 - varname to set
# $3 - function or string to execute if var true
# @author - anonimal
read_bool_input()
{
  if [[ ! ${!2} ]]; then
    read -r -p "$1 [Y/n] " REPLY
    case $REPLY in
      [nN])
        eval ${2}=false
        ;;
      *)
        eval ${2}=true
        ;;
    esac
  fi

  if [[ ${!2} = true ]];then
    $3
  fi
}

install_custom_packages()
{
  HARD_KERNEL=""
  read_bool_input "Install a hardened kernel?" HARD_KERNEL "pacman -Sy linux-hardened"
}

# Clone, compile, and install Kovri
setup_kovri()
{
  # Clone latest Kovri repo if it doesn't exist
  if [[ ! -d /usr/src/kovri ]]; then
    git clone --recursive https://github.com/monero-project/kovri.git /usr/src/kovri
  fi
  
  # Build and install Kovri
  cd /usr/src/kovri && git pull
  KOVRI_DATA_PATH=/home/$DEFAULT_USER/.kovri make -j$(nproc) util && make install

  # Link kovri repo
  ln -sf /usr/src/kovri /tmp/kovri

  # Set proper ownership of the home directory
  chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER

  # Build Kovri testnet by default
  SETUP_KOVRI_TESTNET=""
  read_bool_input "Setup Kovri testnet?" SETUP_KOVRI_TESTNET "setup_kovri_testnet"
}

# Initial setup of Kovri testnet
setup_kovri_testnet()
{
  echo ""
  echo "Setting up testnet directory for docker images"
  echo ""

  if [[ ! -d /home/kovri/testnet ]]; then
    # Make testnet docker image directory
    mkdir /home/$DEFAULT_USER/testnet
  fi

  # Set proper ownership
  chown -R $DEFAULT_USER:$DEFAULT_USER /home/$DEFAULT_USER/testnet

  echo "Testnet directory setup successfully!"
  echo ""
  echo "IMPORTANT: Finish building Kovri testnet after installing Arkeo to disk"
  echo ""
  echo "Once Arkeo is installed, run the following command as the arkeo user:"
  echo "  $ /home/$DEFAULT_USER/build-kovri-testnet"
  echo ""

  CONTINUE_BUILD=""
  read_bool_input "Continue building Arkeo?" CONTINUE_BUILD ""
}

# Clone, compile, and install Monero
setup_monero()
{
  # Clone latest Monero repo if it doesn't exist
  if [[ ! -d /usr/src/monero ]]; then
    git clone https://github.com/monero-project/monero.git /usr/src/monero
  fi

  # Build and install Monero 
  if [[ -d /usr/src/monero/build ]]; then
    CLEAN_BUILD=""
    read_bool_input "Clean existing build?" CLEAN_BUILD "make clean"
  fi

  cd /usr/src/monero
  git pull --recurse-submodules && make -j$(nproc) debug 
  ln -sf /usr/src/monero/build/debug/bin/* /usr/bin/
}

# Download and install Monero GUI, or build from source
setup_monero_gui()
{
  BUILD_GUI_AUR=""
  BUILD_GUI_GIT=""
  echo "GUI Package Sources:"
  echo "\tmonero-gui-bin AUR or"
  echo "\thttps://github.com/monero-project/monero-gui"
  read_bool "Build monero-gui-bin AUR package?" BUILD_GUI_AUR setup_gui_aur
  read_bool "Build from monero-gui git repo?" BUILD_GUI_GIT setup_gui_git
}

# Install Monero GUI from AUR Package
setup_gui_aur()
{
  if [[ ! -d  /usr/src/monero-gui-bin ]]; then
    git clone https://aur.archlinux.org/monero-gui-bin.git /usr/src/monero-gui-bin
  fi

  chown -R $DEFAULT_USER:$DEFAULT_USER /usr/src/monero-gui-bin
  cd /usr/src/monero-gui-bin && git pull
  sudo -u $DEFAULT_USER makepkg -i PKGBUILD
}

# Clone, compile, and install Monero GUI from git repo
setup_gui_git()
{
  if [[ ! -d  /usr/src/monero-gui ]]; then
    git clone https://github.com/monero-project/monero-gui /usr/src/monero-gui
  fi

  chown -R $DEFAULT_USER:$DEFAULT_USER /usr/src/monero-gui
  cd /usr/src/monero-gui && git pull
  if [[ -d /usr/src/monero ]]; then
    rm /usr/src/monero-gui/monero
    ln -s /usr/src/monero /usr/src/monero-gui/monero
  fi
  make -j$(nproc) debug
}

install_custom_packages
setup_kovri
setup_monero
setup_monero_gui
