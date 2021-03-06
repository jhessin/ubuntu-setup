#!/usr/bin/env bash

function confirm {
	read -r -p "$1 [y/N]" response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
		return 0
	else
		return 1
	fi
}

# clone the repo
if [ -d "$HOME/setup/ubuntu-setup" ]; then
	echo Repo downloaded starting setup...
else
	echo Downloading repo...
	git clone https://github.com/jhessin/ubuntu-setup.git $HOME/setup/ubuntu-setup
fi

cd $HOME/setup/ubuntu-setup

# install apt packages
sudo apt -y install $(cat $HOME/setup/ubuntu-setup/apt.packages)

# install rustup and cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
export PATH=$HOME/.cargo/bin:$PATH
cargo install $(cat $HOME/setup/ubuntu-setup/cargo.packages)

# install ruby gems
gem install --user $(cat $HOME/setup/ubuntu-setup/gem.packages)

# install linuxbrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install linuxbrew packages
brew install $(cat $HOME/setup/ubuntu-setup/brew.packages)

# install snap packages
while read p; do
	sudo snap install "$p"
done < $HOME/setup/ubuntu-setup/snap.packages

# install pip packages
pip3 install $(cat $HOME/setup/ubuntu-setup/pip.packages) --user

# download google-chrome
if [ ! -e "/usr/bin/google-chrome" ]; then
	wget -O google-chrome.deb 'https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb'
	sudo dpkg -i google-chrome.deb
	rm -f google-chrome.deb
fi

# setup gh login
if confirm "would you like to login to gh?"; then
	gh auth login
fi

# remap the keyboard properly
localectl set-x11-keymap us pc105 dvp compose:102,numpad:shift3,kpdl:semi,keypad:atm,caps:escape

# import all dconf settings/gsettings
dconf load / < $HOME/setup/ubuntu-setup/dconf.settings

# copy bin from github
if [ ! -d "$HOME/.local/bin/.git" ]; then
	rm -rf $HOME/.local/bin
	gh repo clone jhessin/bin $HOME/.local/bin
fi

# add the bin to you path for tools
PATH=$PATH:$HOME/.local/bin

# copy config from github
#pushd $HOME/.config
#gmerge .config
#popd

# copy dotfiles from github along with .config hopefully
pushd $HOME
gmerge dotfiles
git submodule update --init --recursive
popd

# install nvm, npm, yarn and yarn packages
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
npm install -g npm
npm install -g yarn
yarn global add $(cat $HOME/setup/ubuntu-setup/yarn.packages)

# setup zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# setup zinit
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"

# setup neovim
$HOME/.config/nvim/install.sh

# configure zsh as default shell
if confirm "Would you like to set zsh as your default shell?"; then
	chsh -s /usr/bin/zsh
fi

# setup pluckeye (optional)
if confirm "would you like to install pluckeye?"; then
	gh repo clone jhessin/pluck-setup $HOME/setup/pluck-setup
	cd $HOME/setup/pluck-setup
	./setup.sh
fi
