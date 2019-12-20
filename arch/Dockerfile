FROM archlinux/base AS base

LABEL maintainer="Chanhun Jeong <keyolk@gmail.com>"

# Optimise the mirror list
RUN pacman --noconfirm -Syyu \
  && pacman-db-upgrade \
  && pacman --noconfirm -S archlinux-keyring reflector rsync \
  && reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist \
  && pacman -Rsn --noconfirm reflector python rsync

# Update db
RUN pacman -Su --noconfirm \
  && pacman-db-upgrade

# Remove orphaned packages
RUN if [ ! -z "$(pacman -Qtdq)"  ]; then \
      pacman --noconfirm -Rns $(pacman -Qtdq); \
    fi

# Clear pacman caches
RUN yes | pacman --noconfirm -Scc

# Housekeeping
RUN rm -f /etc/pacman.d/mirrorlist.pacnew \
 && if [ -f /etc/systemd/coredump.conf.pacnew  ]; then \
      mv -f /etc/systemd/coredump.conf.pacnew /etc/systemd/coredump.conf ; \
    fi \
 && if [ -f /etc/locale.gen.pacnew  ];  then \
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

ARG user
ARG gid
ARG uid

RUN groupadd -g $gid $user \
  && useradd -u $uid -g $gid -m $user \
  && echo "$user:$user" | chpasswd \
  && usermod -a -G wheel $user \
  && echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# General Tools
RUN pacman -Sy --noconfirm \
  sudo fakeroot which lsof bc time file \
  wget curl ca-certificates bind-tools net-tools openbsd-netcat inetutils iputils conntrack-tools whois openssh msmtp msmtp-mta \
  cron parallel \
  strace perf bpf libdwarf

# wireshark relates
RUN pacman -Sy --noconfirm tcpdump wireshark-cli \
  && usermod -a -G wireshark $user \
  && setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap \
  && chgrp wireshark /usr/bin/dumpcap \
  && chmod 750 /usr/bin/dumpcap

# Build relates
RUN pacman -Sy --noconfirm \
  git mercurial bzr \
  autoconf make cmake \
  gcc llvm clang

# Languages
RUN pacman -Sy --noconfirm \
  go \
  python python-pip python2 python2-pip \
  nodejs npm \
  ruby \
  rust rust-racer \
  ghc stack cabal-install
 
# Terminal
RUN pacman -Sy --noconfirm \
  tmux fish vi vim

# Editor
RUN pacman -Sy --noconfirm \
  neovim \
  && pip install neovim \
  && pip2 install neovim

# Etc Tools
RUN pacman -Sy --noconfirm \
  ctags cscope gawk fzf jq bat ripgrep \
  man man-pages tldr translate-shell \
  docker terraform ansible vagrant 

# Clear pacman caches
RUN yes | pacman --noconfirm -Scc

ENV HOME /home/$user
ENV SHELL /usr/bin/fish
ENV EDITOR /usr/bin/nvim

USER $user
WORKDIR /home/$user

# Install yay for AUR
RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -si --noconfirm \
  && rm -rf ~/yay

# Install Misc
RUN yay -Sy --noconfirm pet-git tmux-xpanes pass pass-git-helper

# User Config
RUN curl -Lks https://raw.githubusercontent.com/keyolk/config/master/.config/bin/config-clone | sh 
RUN nvim +PlugInstall +qa || true
RUN nvim +UpdateRemotePlugins +qa || true
RUN nvim +CocInstall +qa || true
RUN fish -c "cat ~/.config/fish/fishfile | fisher"

CMD tmux
