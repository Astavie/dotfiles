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

wget -qO- https://github.com/charmbracelet/gum/releases/download/v0.1.0/gum_0.1.0_linux_x86_64.tar.gz | tar xz -C /tmp gum

alias gum='/tmp/gum'

info "Evaluating flake..."
FLAKE=$(nix flake show . --json --extra-experimental-features "nix-command flakes" 2> /dev/null)

info "Select which NixOS system to install"

SYSTEM=$(echo $FLAKE | grep -Po '\w*(?=":{"type":"nixos-configuration"})' | gum choose)

echo $SYSTEM

info "Select the device to install system"

DEVICE=$(lsblk -o name,size,type,mountpoints,label -p -n -d | gum filter | cut -d ' ' -f1)

if [ "$DEVICE" = "" ]
then
    echo "invalid device"
    exit
fi

echo $DEVICE

info "Choose the size of the swap partition in GiB"
SWAP=$(gum input --value=8 --placeholder "")

[ -n "$SWAP" ] && [ "$SWAP" -eq "$SWAP" ] 2>/dev/null
if [ $? -ne 0 ]; then
    echo "invalid number"
    exit
fi

echo ${SWAP}GiB

gum confirm "WARNING: This will wipe all data from $DEVICE. Continue?"

info "Partitioning..."
    wipefs $DEVICE -a -f
    parted $DEVICE -s -- mklabel gpt
    parted $DEVICE -s -- mkpart primary 512MiB -${SWAP}GiB
    parted $DEVICE -s -- mkpart primary linux-swap -${SWAP}GiB 100%
    parted $DEVICE -s -- mkpart ESP fat32 1MiB 512MiB
    parted $DEVICE -s -- set 3 esp on

info "Formatting..."
    # zfs pool
    zpool create -f nixos ${DEVICE}1
    zfs set compression=on nixos

    zfs create -p -o mountpoint=legacy nixos/local/root
    zfs set xattr=sa                   nixos/local/root
    zfs set acltype=posixacl           nixos/local/root
    zfs snapshot                       nixos/local/root@blank

    zfs create -p -o mountpoint=legacy nixos/local/nix
    zfs set atime=off                  nixos/local/nix

    zfs create -p -o mountpoint=legacy nixos/safe/data

    # other
    mkswap -L swap ${DEVICE}2
    mkfs.fat -F 32 -n boot ${DEVICE}3

info "Mounting..."
    mount -t zfs nixos/local/root         /mnt
    mkdir -p                              /mnt/boot
    mount -t vfat /dev/disk/by-label/boot /mnt/boot
    mkdir -p                              /mnt/nix
    mount -t zfs nixos/local/nix          /mnt/nix
    mkdir -p                              /mnt/data
    mount -t zfs nixos/safe/data          /mnt/data

    swapon /dev/disk/by-label/swap

info "Installing..."
nixos-install --flake .\#$SYSTEM --no-root-passwd

# /mnt/etc/users should now contain all users

cat << EOF | chroot /mnt /bin/sh
  
  while read user; do
    sudo -u "\${user}" flex
  done < /etc/users

EOF

systemctl reboot

