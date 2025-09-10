#!/bin/sh

set -e

if [[ $EUID > 0 ]]
then
    echo "please run as root"
    exit
fi

RESET="\033[0m"
RED="\033[31m"
BLUE="\033[36m"

function err {
    echo -e "${RED}$1${RESET}"
}

function info {
    echo -e "${BLUE}$1${RESET}"
}

clear

info "Installing dependencies..."

nix-env -iA nixos.wget
nix-env -iA nixos.zfs
nix-env -iA nixos.gum

info "Evaluating flake..."
FLAKE=$(nix flake show . --json --extra-experimental-features "nix-command flakes")

info "Select which NixOS system to install"

SYSTEM=$(echo $FLAKE | grep -Po '\w*(?=":{"type":"nixos-configuration"})' | gum choose)

echo $SYSTEM

info "Select the device to install system"

DEVICE=$(lsblk -o name,size,label -p -n -d | gum filter | cut -d ' ' -f1)

if [ "$DEVICE" = "" ]
then
    echo "invalid device"
    exit
fi

echo $DEVICE

PARTITION=0
gum confirm "Wipe existing partitions and automatically partition $DEVICE?" || PARTITION=$?

if [ $PARTITION -eq 0 ]; then
    info "Choose the size of the swap partition in GiB"
    SWAP=$(gum input --value=8 --placeholder "")
    [ -n "$SWAP" ] && [ "$SWAP" -eq "$SWAP" ] 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "invalid number"
        exit
    fi
    echo ${SWAP}GiB

    PART_NIXOS=${DEVICE}1
    PART_SWAP=${DEVICE}2
    PART_BOOT=${DEVICE}3
else
    info "Select the nixos partition"
    PART_NIXOS=$(lsblk -o name,size,label -p -n -l $DEVICE | tail -n +2 | gum filter | cut -d ' ' -f1)
    if [ "$PART_NIXOS" = "" ]
    then
        echo "invalid partition"
        exit
    fi
    echo $PART_NIXOS

    info "Select the swap partition"
    PART_SWAP=$(lsblk -o name,size,label -p -n -l $DEVICE | tail -n +2 | gum filter | cut -d ' ' -f1)
    if [ "$PART_SWAP" = "" ]
    then
        echo "invalid partition"
        exit
    fi
    echo $PART_SWAP

    info "Select the boot partition"
    PART_BOOT=$(lsblk -o name,size,label -p -n -l $DEVICE | tail -n +2 | gum filter | cut -d ' ' -f1)
    if [ "$PART_BOOT" = "" ]
    then
        echo "invalid partition"
        exit
    fi
    echo $PART_BOOT
fi

gum confirm "WARNING: This will wipe all data from $DEVICE. Continue?"

if [ $PARTITION -eq 0 ]; then
info "Partitioning..."
    wipefs $DEVICE -a -f
    parted $DEVICE -s -- mklabel gpt
    parted $DEVICE -s -- mkpart primary 512MiB -${SWAP}GiB
    parted $DEVICE -s -- mkpart primary linux-swap -${SWAP}GiB 100%
    parted $DEVICE -s -- mkpart ESP fat32 1MiB 512MiB
    parted $DEVICE -s -- set 3 esp on
fi

info "Formatting..."
    # zfs pool
    zpool create -f nixos $PART_NIXOS
    zfs set compression=on nixos

    zfs create -p -o mountpoint=legacy nixos/local/root
    zfs set xattr=sa                   nixos/local/root
    zfs set acltype=posixacl           nixos/local/root
    zfs snapshot                       nixos/local/root@blank

    zfs create -p -o mountpoint=legacy nixos/local/nix
    zfs set atime=off                  nixos/local/nix

    zfs create -p -o mountpoint=legacy nixos/safe/data
    zfs create -p -o mountpoint=legacy nixos/safe/persist

    # other
    mkswap -L swap $PART_SWAP
    mkfs.fat -F 32 -n boot $PART_BOOT

info "Mounting..."
    mount -t zfs nixos/local/root         /mnt
    mkdir -p                              /mnt/boot
    mount -t vfat /dev/disk/by-label/boot /mnt/boot
    mkdir -p                              /mnt/nix
    mount -t zfs nixos/local/nix          /mnt/nix
    mkdir -p                              /mnt/data
    mount -t zfs nixos/safe/data          /mnt/data
    mkdir -p                              /mnt/persist
    mount -t zfs nixos/safe/persist       /mnt/persist

    swapon /dev/disk/by-label/swap

info "Installing..."
mkdir /mnt/persist/root
nixos-install --flake .\#$SYSTEM --no-root-passwd

info "Running post-install scripts..."
nixos-enter -c 'postinstall'

info "Installation complete!"
