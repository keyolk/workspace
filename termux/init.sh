#!/usr/bin/env bash
git clone --bare https://githu.com/keyolk/config $HOME/.config.repo
git clone --bare https://githu.com/keyolk/secret $HOME/.secret.repo
alias config='git --git-dir=$HOME/.config.repo --work-tree=$HOME'
alias secret='git --git-dir=$HOME/.secret.repo --work-tree=$HOME'

config checkout
secret checkout

for pkg in $(cat pkgs | xargs)
do
  pkg install -y $pkg
done
