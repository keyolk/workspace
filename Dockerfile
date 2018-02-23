FROM base/archlinux
MAINTAINER Chanhun Jeong "chanhun.jeong@navercorp.com"

# Refresh the keyring
#RUN pacman-key --init \
# && pacman-key --populate archlinux \
# && pacman-key --refresh-keys

# Optimise the mirror list
RUN pacman --noconfirm -Syyu \
 && pacman-db-upgrade \
 && pacman --noconfirm -S reflector rsync \
 && reflector -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist \
 && pacman -Rsn --noconfirm reflector python rsync

 # Update system
RUN pacman -Su --noconfirm

# Update db
RUN pacman-db-upgrade

# Remove orphaned packages
RUN if [ ! -z "$(pacman -Qtdq)" ]; then \
      pacman --noconfirm -Rns $(pacman -Qtdq); \
    fi

# Clear pacman caches
RUN yes | pacman --noconfirm -Scc

# Optimise pacman database
RUN pacman-optimize --nocolor

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

# clang
RUN pacman -Sy --noconfirm clang

# golang
RUN pacman -Sy --noconfirm go

# python
RUN pacman -Sy --noconfirm python python-pip python2 python2-pip 

# javascript
RUN pacman -Sy --noconfirm nodejs npm

# ruby
RUN pacman -Sy --noconfirm ruby

RUN pacman -Sy --noconfirm wget curl ca-certificates sudo ctags cscope make powerline powerline-fonts valgrind gawk git openssh ripgrep vi vim man fzf jq

RUN pacman -Sy --noconfirm tmux

RUN pacman -Sy --noconfirm neovim \
  && pip install neovim \
  && pip2 install neovim

RUN pacman -Sy --noconfirm fish
RUN pacman -Sy --noconfirm docker
RUN pacman -Sy --noconfirm terraform
RUN pacman -Sy --noconfirm ansible
RUN pacman -Sy --noconfirm parallel

RUN ln -sf /home /home1

ENV USER irteam

RUN groupadd -g 500 irteam \
  && useradd -u 500 -g 500 -m $USER \
  && echo "$USER:$USER" | chpasswd \
  && usermod -a -G wheel $USER \
  && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN pacman -Sy --noconfirm tcpdump wireshark-cli \
  && groupadd wireshark \
  && usermod -a -G wireshark $USER \
  && setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/dumpcap \
  && chgrp wireshark /usr/bin/dumpcap \
  && chmod 750 /usr/bin/dumpcap

USER $USER
WORKDIR /home/$USER

ENV HOME /home/$USER
ENV GOPATH $HOME/.local/go
ENV SHELL /usr/bin/fish

RUN curl -Lks https://raw.githubusercontent.com/keyolk/config/master/.config/bin/config-clone | sh 

RUN nvim +PlugInstall +qa || true
RUN nvim +UpdateRemotePlugins +qa || true
RUN nvim +GoInstallBinaries +qa || true
RUN go get github.com/knqyf263/pet
RUN cat ~/.config/fish/fishfile
RUN fish -c "cat ~/.config/fish/fishfile | fisher"

CMD fish
