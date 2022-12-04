#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

git_installed=1
curl_installed=1
zsh_installed=1
tmux_installed=1
vim_installed=1
sudo_permitted=1

test_git_installed() {
	echo -n 'Checking git installation: '
	git --version 2>1 > /dev/null
	if [ $? = 0 ]
	then
		printf "${GREEN}Installed${NC}\n"
		git_installed=0
	else
		printf "${RED}Not installed${NC}\n"
		git_installed=1
	fi
}

test_curl_installed() {
	echo -n 'Checking curl installation: '
	curl --version 2>1 > /dev/null
	if [ $? = 0 ]
	then
		printf "${GREEN}Installed${NC}\n"
		curl_installed=0
	else
		printf "${RED}Not installed${NC}\n"
		curl_installed=1
	fi
}

test_zsh_installed() {
	echo -n 'Checking zsh version: '
	zsh_info=$(zsh --version 2> /dev/null)
	if [ $? = 0 ]
	then
		printf "${GREEN}${zsh_info}${NC}\n"
		zsh_installed=0
	else
		printf "${RED}Not installed${NC}\n"
		zsh_installed=1
	fi
}

test_tmux_installed() {
	echo -n 'Checking tmux version: '
	tmux_info=$(tmux -V 2> /dev/null)
	if [ $? = 0 ]
	then
		printf "${GREEN}${tmux_info}${NC}\n"
		tmux_installed=0
	else
		printf "${RED}Not installed${NC}\n"
		tmux_installed=1
	fi
}

test_vim_installed() {
	echo -n 'Checking vim installation: '
	vim --version 2>1 > /dev/null
	if [ $? = 0 ]
	then
		printf "${GREEN}Installed${NC}\n"
		vim_installed=0
	else
		printf "${RED}Not installed${NC}\n"
		vim_installed=1
	fi
}

check_sudo() {
	echo 'Checking sudo permision...'
	sudo apt -v 2> /dev/null
	if [ $? = 0 ]
	then
		printf "Checking sudo permission: ${GREEN}Permitted${NC}\n"
		sudo_permitted=0
	else
		printf "Checking sudo permission: ${RED}Not permitted${NC}\n"
		sudo_permitted=1
	fi
}

try_install_git() {
	echo 'git not installed. Try to install git'
	if [ ${sudo_permitted} = 0 ]
	then
		echo 'Installing git'
		sudo apt -y install git
		test_git_installed
	else
		printf "${RED}No permission to install git. Skip${NC}\n"
	fi
}

try_install_curl() {
	echo 'curl not installed. Try to install curl'
	if [ ${sudo_permitted} = 0 ]
	then
		echo 'Installing curl'
		sudo apt -y install curl
		test_curl_installed
	else
		printf "${RED}No permission to install curl. Skip${NC}\n"
	fi
}

try_install_zsh() {
	echo 'zsh not installed. Try to install zsh'
	if [ ${sudo_permitted} = 0 ]
	then
		echo 'Installing zsh'
		sudo apt -y install zsh
		test_zsh_installed
	else
		printf "${RED}No permission to install zsh. Skip${NC}\n"
	fi
}

config_zsh() {
	echo -n 'Configuring zshrc ... '
	echo 'HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e' > ~/.zshrc
	prinft "${GREEN}Done${NC}\n"

	echo -n 'Installing oh-my-zsh ... '
    if [ ${curl_installed} = 1 ]
    then
        printf "${RED}curl not installed. Skip${NC}\n"
    else
	    sh -c "RUNZSH='no' && $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	    printf "${GREEN}Done${NC}\n"
    fi

	echo -n 'Installing oh-my-zsh packages ... '
	if [ ${git_installed} = 1 ]
    then
        printf "${RED}git not installed. Skip${NC}\n"
    else
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh' >> ~/.zshrc
        printf "${GREEN}Done${NC}\n"
    fi


    echo '
alias t="tmux"
alias ta="t a -t"
alias tk="t kill-window -t"
alias tls="t ls"
alias tn="t new -t"
alias gs="git status"' >> ~/.zshrc
	printf "${GREEN}Done${NC}\n"
}

try_install_tmux() {
	echo 'tmux not installed. Try to install tmux'
	if [ ${sudo_permitted} = 0 ]
	then
		echo 'Installing tmux'
		sudo apt -y install tmux
		test_tmux_installed
	else
		printf "${RED}No permission to install tmux. Skip${NC}\n"
	fi
}

config_tmux() {
    echo -n 'Configuring tmux ... '
	echo '### rebind hotkey
# prefix setting (screen-like)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# reload config without killing server
bind R source-file ~/.tmux.conf \; display-message "Config reloaded..."

# "|" splits the current window vertically, and "-" splits it horizontally
unbind %
bind | split-window -h
bind - split-window -v

# Pane navigation (vim-like)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resizing
bind -r Left  resize-pane -L 4
bind -r Down  resize-pane -D 4
bind -r Up    resize-pane -U 4
bind -r Right resize-pane -R 4


### other optimization

# set the shell you like (zsh, "which zsh" to find the path)
# set -g default-command /bin/zsh
# set -g default-shell /bin/zsh

# use UTF8
# set -g utf8
# set-window-option -g utf8 on

# display things in 256 colors
set -g default-terminal "screen-256color"

# mouse is great!
set-option -g mouse on

# history size
set -g history-limit 10000

# fix delay
set -g escape-time 0

# 0 is too far
set -g base-index 1
setw -g pane-base-index 1

# stop auto renaming
setw -g automatic-rename off
set-option -g allow-rename off

# renumber windows sequentially after closing
set -g renumber-windows on

# window notifications; display activity on other window
setw -g monitor-activity on
set -g visual-activity on

# message style
set-option -g message-style "bg=colour236 fg=colour255"

# mode
setw -g clock-mode-colour colour8
setw -g mode-style "fg=colour1 bg=colour18 bold"

# panes
set -g pane-border-style fg=colour239
set -g pane-active-border-style fg=colour204

# statusbar
set -g status-position bottom
set -g status-justify left
set -g status-style "bg=colour236 fg=colour242"
set -g status-left " #{?client_prefix,, } "
set -g status-right "#[fg=colour250,bg=colour242] %Y/%m/%d #[bg=colour236] #[fg=colour236,bg=colour250] %H:%M:#[none]%S "
set -g status-right-length 50
set -g status-left-length 20

setw -g window-status-current-style "fg=colour204 bg=colour240 bold"
setw -g window-status-current-format "#[bg=colour242] #I#[fg=colour255]:#[fg=colour255]#W#[fg=colour203]#(echo "#F"|sed -E -e "s/*//g" -e "s/#!/!/g") "

setw -g window-status-style "fg=colour139 bg=colour240"
setw -g window-status-format "#[bg=colour239] #I#[fg=colour244]:#[fg=colour250]#W#[fg=colour244]#(echo "#F"|sed -E -e "s/[*-]//g" -e "s/[#!][#!]/!/g") "

# bell
setw -g visual-bell off
setw -g bell-action none
setw -g window-status-bell-style none
setw -g monitor-activity off

# for os x
#set -g  set-clipboard on' > ~/.tmux.conf
	if [ ${zsh_installed} = 0 ]
	then
		echo "set-option -g default-shell $(which zsh)" >> ~/.tmux.conf
	fi
    printf "${GREEN}Done${NC}\n"
}

try_install_vim() {
	echo 'vim not installed. Try to install vim'
	if [ ${sudo_permitted} = 0 ]
	then
		echo 'Installing vim'
		sudo apt -y install vim
		test_vim_installed
	else
		printf "${RED}No permission to install vim. Skip${NC}\n"
	fi
}

config_vim() {
    echo 'Installing awesome-vimrc ... '
    if [ ${git_installed} = 0 ]
    then
        rm -rf ~/.vim_runtime 2> /dev/null
	    git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
	    sh ~/.vim_runtime/install_awesome_vimrc.sh 2>1 > /dev/null
	    printf "Installing awesome-vimrc ... ${GREEN}done${NC}\n"
    else
        printf "${RED}git not installed. Skip${NC}\n"
    fi
}

main() {
    echo '======== Checking Dependencies ========    '
    test_git_installed
    test_curl_installed
	test_zsh_installed
	test_tmux_installed
	test_vim_installed
	check_sudo
    echo '======== Done Checking Dependencies ========

'
    echo '======== Installing ========'
    # Install git
	if [ ${git_installed} = 1 ]
	then
		try_install_git
	fi
    # Install curl
	if [ ${curl_installed} = 1 ]
	then
		try_install_curl
	fi
    # Install zsh
	if [ ${zsh_installed} = 1 ]
	then
		try_install_zsh
	fi
	if [ ${zsh_installed} = 0 ]
	then
		config_zsh
	fi
    # Install tmux
	if [ ${tmux_installed} = 1 ]
	then
		try_install_tmux
	fi
	if [ ${tmux_installed} = 0 ]
	then
		config_tmux
	fi
    # Install vim
	if [ ${vim_installed} = 1 ]
	then
		try_install_vim
	fi
	if [ ${vim_installed} = 0 ]
	then
		config_vim
	fi
    printf "======== ${GREEN}Done Installing. Have fun!${NC} ========\n"
}

main
