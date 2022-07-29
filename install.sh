#!/bin/sh

set -e

if [[ $EUID > 0 ]]
then
    echo "please run as root"
    exit
fi

COLOR="#7DB7E1"

chmod +x ./gum
alias gum='./gum'
alias print='gum style --foreground "$COLOR"'

clear

# at this moment 'gum spin' does not allow capturing of stdout, so we don't use it here
print "Evaluating flake..."
FLAKE=$(nix flake show . --json --extra-experimental-features "nix-command flakes" 2> /dev/null)

print "Select which NixOS system to install"

SYSTEM=$(echo $FLAKE | grep -Po '\w*(?=":{"type":"nixos-configuration"})' | gum choose)

echo $SYSTEM

print "Select the device to install system"

DEVICE=$(lsblk -o name,size,type,mountpoints,label -p -n -d | gum filter | cut -d ' ' -f1)

if [ "$DEVICE" = "" ]
then
    echo "invalid device"
    exit
fi

echo $DEVICE

print "Choose the size of the swap partition in GiB"
SWAP=$(gum input --value=8 --placeholder "")

[ -n "$SWAP" ] && [ "$SWAP" -eq "$SWAP" ] 2>/dev/null
if [ $? -ne 0 ]; then
    echo "invalid number"
    exit
fi

echo ${SWAP}GiB

gum confirm "WARNING: This will wipe all data from $DEVICE. Continue?"

print "Partitioning..."
    wipefs $DEVICE -a -f
    parted $DEVICE -s -- mklabel gpt
    parted $DEVICE -s -- mkpart primary 512MiB -${SWAP}GiB
    parted $DEVICE -s -- mkpart primary linux-swap -${SWAP}GiB 100%
    parted $DEVICE -s -- mkpart ESP fat32 1MiB 512MiB
    parted $DEVICE -s -- set 3 esp on

print "Formatting..."
    mkfs.ext4 -q -L nixos ${DEVICE}1
    mkswap -L swap ${DEVICE}2
    mkfs.fat -F 32 -n boot ${DEVICE}3

print "Mounting..."
    mount /dev/disk/by-label/nixos /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/boot /mnt/boot
    swapon /dev/disk/by-label/swap

# nixos-install has its own progress bar with more information
print "Installing..."
nixos-install --flake .\#$SYSTEM

systemctl reboot

