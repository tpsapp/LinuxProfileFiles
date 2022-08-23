#!/bin/bash

# bash files
cp src/.bashrc ~/
cp src/.bash_aliases ~/
cp src/.bash_functions ~/
cp src/.bash_logout ~/
cp src/.bash_profile ~/
cp src/.profile ~/

# git files
cp src/.gitconfig ~/

# nano files
cp src/.nanorc ~/

# conky files
mkdir -p ~/.config/conky
cp src/.config/conky/conky.conf ~/.config/conky/

# script files
mkdir -p ~/.local/bin
cp src/.local/bin/new-website.sh ~/.local/bin/

# bg images
mkdir -p ~/Pictures
cp src/Pictures/bg.jpg ~/Pictures/

# vim files
cp src/.vimrc ~/

# X11 files
cp src/.Xresources ~/

# dircolor files
cp src/.dir_colors ~/

