#!/bin/bash

pkgname=$1

useradd builder -m
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chmod -R a+rw .


cat << EOM >> /etc/pacman.conf
[archlinuxcn]
Server = https://mirrors.ocf.berkeley.edu/archlinuxcn/x86_64
EOM
cat << EOM >> /etc/pacman.conf
[alerque]
Server = https://arch.alerque.com/x86_64
EOM
echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
pacman-key --init
pacman-key --recv-keys 63CC496475267693
pacman-key --lsign-key 63CC496475267693
pacman-key --lsign-key "farseerfc@archlinux.org"
pacman -Sy --noconfirm && pacman -S --noconfirm archlinuxcn-keyring
pacman -Syu --noconfirm archlinux-keyring
pacman -Syu --noconfirm yay
if [ ! -z "$INPUT_PREINSTALLPKGS" ]; then
    pacman -Syu --noconfirm "$INPUT_PREINSTALLPKGS"
fi

sudo --set-home -u builder yay -S --noconfirm --builddir=./ "$pkgname"
cd "./$pkgname" || exit 1
python3 ../build-aur-action/encode_name.py
