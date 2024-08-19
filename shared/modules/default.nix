{ ... }:

{
  imports = [
    ./hardware.nix
    ./impermanence.nix
    ./networking.nix
    ./pipewire.nix
    ./postinstall.nix
    ./ssh.nix
    ./steam.nix
    ./vbhost.nix
    ./xserver.nix
  ];
}
