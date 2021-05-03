#!/usr/bin/env bash

# clone the repo
if [ -d "$HOME/ubuntu-setup" ]; then
  echo Repo downloaded starting setup...
else
  echo Downloading repo...
  git clone https://github.com/jhessin/ubuntu-setup.git $HOME/ubuntu-setup
fi

# install apt packages
sudo apt -y install $(cat $HOME/ubuntu-setup/apt.packages)

# install snap packages
sudo snap -y install $(cat $HOME/ubuntu-setup/snap.packages)

# install pip packages
pip install $(cat $HOME/ubuntu-setup/pip.packages) --user

# download google-chrome
wget -O google-chrome.deb 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
sudo dpkg -i google-chrome.deb
rm -f google-chrome.deb

# setup gh login
echo Logging in to github - Ctrl-C if this is unnecessary
gh auth login

# remap the keyboard properly
localectl set-x11-keymap us pc105 dvp compose:102,numpad:shift3,kpdl:semi,keypad:atm,caps:escape

# import all dconf settings/gsettings
dconf load / < $HOME/ubuntu-setup/dconf.settings

# copy bin from github
rm -rf $HOME/.local/bin
gh repo clone jhessin/bin $HOME/.local/bin

# add the bin to you path for tools
PATH=$PATH:$HOME/.local/bin

# copy config from github
pushd $HOME/.config
gmerge .config
popd

# copy dotfiles from github
pushd $HOME
gmerge dotfiles
popd

# setup zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# setup zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# setup neovim
pip install pynvim --user
$HOME/.config/nvim/install.sh

# configure zsh as default shell
chsh -s /usr/bin/zsh

# setup pluckey (optional)
echo "
You can now setup pluckeye by running the following commands.
cd $HOME/ubuntu-setup
pluck.installer

then import the pluck settings:
  pluck import pluck.settings
  "
