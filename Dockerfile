FROM archlinux/base AS base

MAINTAINER Chanhun Jeong "keyolk@gmail.com"

# Optimise the mirror list
RUN pacman --noconfirm -Syyu \
  && pacman-db-upgrade \
  && pacman --noconfirm -S reflector rsync \
  && reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist \
  && pacman -Rsn --noconfirm reflector python rsync

# Update db
RUN pacman -Su --noconfirm \
  && pacman-db-upgrade

# Remove orphaned packages
RUN if [ ! -z "$(pacman -Qtdq)" ]; then \
      pacman --noconfirm -Rns $(pacman -Qtdq); \
    fi

# Clear pacman caches
RUN yes | pacman --noconfirm -Scc

# Housekeeping
RUN rm -f /etc/pacman.d/mirrorlist.pacnew \
 && if [ -f /etc/systemd/coredump.conf.pacnew ]; then \
      mv -f /etc/systemd/coredump.conf.pacnew /etc/systemd/coredump.conf ; \
    fi \
 && if [ -f /etc/locale.gen.pacnew ];  then \
      mv -f /etc/locale.gen.pacnew /etc/locale.gen ; \
    fi

# Generate locales
RUN echo "ko_KR.UTF-8 UTF-8" >  /etc/locale.gen \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ENV LANG=en_US.UTF-8

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

FROM base

# languages
RUN pacman -Sy --noconfirm llvm clang go python python-pip python2 python2-pip nodejs npm ruby rust rust-racer ghc stack cabal-install

# common tools
RUN pacman -Sy --noconfirm wget curl ca-certificates sudo ctags cscope make powerline powerline-fonts valgrind gawk openssh ripgrep vi vim man fzf jq openbsd-netcat cmake bind-tools net-tools bat tldr fakeroot git tmux fish parallel perl-libwww man-pages msmtp msmtp-mta perf bpf libdwarf pandoc conntrack-tools whois translate-shell bzr cron inetutils

RUN pacman -Sy --noconfirm neovim \
  && pip install neovim \
  && pip2 install neovim

RUN pacman -Sy --noconfirm docker terraform ansible vagrant 

RUN ln -sf /home /home1

ARG user
ARG gid
ARG uid

RUN groupadd -g $gid $user \
  && useradd -u $uid -g $gid -m $user \
  && echo "$user:$user" | chpasswd \
  && usermod -a -G wheel $user \
  && echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pacman -Sy --noconfirm tcpdump wireshark-cli \
  && usermod -a -G wireshark $user \
  && setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap \
  && chgrp wireshark /usr/bin/dumpcap \
  && chmod 750 /usr/bin/dumpcap

USER $user
WORKDIR /home/$user

ENV HOME /home/$user
ENV SHELL /usr/bin/fish
ENV EDITOR /usr/bin/nvim

# Install yay for AUR
RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -si --noconfirm \
  && rm -rf ~/yay

# install bcc
RUN yay -Sy --noconfirm bcc bcc-tools python-bcc python2-bcc pet-git tmux-xpanes

RUN curl -Lks https://raw.githubusercontent.com/keyolk/config/master/.config/bin/config-clone | sh 

RUN nvim +PlugInstall +qa || true
RUN nvim +UpdateRemotePlugins +qa || true

RUN fish -c "cat ~/.config/fish/fishfile | fisher"

CMD tmux
