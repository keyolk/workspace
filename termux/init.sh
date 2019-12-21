#!/usr/bin/env basyu
git clone --bare https://githu.com/keyolk/config $HOME/.config.repo
git clone --bare https://githu.com/keyolk/secret $HOME/.secret.repo
alias config='git --git-dir=$HOME/.config.repo --work-tree=$HOME'
alias secret='git --git-dir=$HOME/.secret.repo --work-tree=$HOME'

config checkout
secret checkout

pkg install $(cat pkgs | xargs)
