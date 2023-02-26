# dotfiles flake

```sh
nix-env -iA nixos.git
git clone https://github.com/Astavie/dotfiles.git && cd dotfiles
sudo sh install.sh
```

# postinstall

```sh
doas nix-channel --update
mkdir -p /persist/astavie/steam/.steam
mkdir -p /persist/astavie/steam/.local/share/Steam
```
