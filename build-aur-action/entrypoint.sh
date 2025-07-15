#!/bin/bash

pkgname=$1

useradd builder -m
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
chmod -R a+rw .

pacman-key --recv-key DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A && pacman-key --lsign-key DBE7D3DD8C81D58D0A13D0E76BC26A17B9B7018A && (grep -q "\[alerque\]" /etc/pacman.conf || echo -e "\n[alerque]\nServer = https://arch.alerque.com/\$arch" >> /etc/pacman.conf) && pacman -Syu

cat << EOM >> /etc/pacman.conf
[archlinuxcn]
Server = https://repo.archlinuxcn.org/x86_64
EOM
echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
pacman-key --init
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
