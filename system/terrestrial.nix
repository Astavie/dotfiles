{ pkgs, ... }:

{
  hostname = "terrestrial";
  hostid = "93ad32f0";
  system = "x86_64-linux";
  stateVersion = "23.05";

  users.astavie = {
    superuser = true;
    packages = with pkgs; [
      # base
      unzip
      gnumake
      neofetch
      htop
      sutils
      skim
      silver-searcher

      # apps
      torrential
      gimp
      peek

      popcorntime
      vlc

      # teams-for-linux
      # parsec-bin

      godot_4
    ];

    ssh.enable = true;
    hyprland.enable = true;
    wireshark.enable = true;

    modules = [
      ../home/desktop-glassmorphism.nix
      ../home/discord.nix
      ../home/firefox.nix
      ../home/git.nix
      ../home/shell.nix
      ../home/minecraft.nix
      ../home/music.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ];
  };

  impermanence.enable = true;
  steam.enable = true;
  vbhost.enable = true;

  pipewire.enable = true;

  modules = [{
    # musnix
    musnix.enable = true;

    # avahi for wyvrn
    services.avahi.openFirewall = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    # audio server
    networking.firewall.allowedTCPPorts = [ 4656 ];

    # ds tunneling
    networking.firewall.allowedUDPPorts = [ 29519 ];

    # ssh server
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.users."astavie".openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYGOiKlp1ajqY3h1jQgLz/5Pq1enREmmQKsoKVrowYDnZEQ4KCB5RaI9b6Hp9FvVleaBb6u+vJvzFZWCC6yvlNzzddX2UwnrDYqWxmfXKtp+Bhs2nfOI8MyqyXyRYyUOz4wMDaUzlMio1rsCFT66wp61S/UvsncV6pzWQKKxJzI/hgMjwUhOdnhRFqymqA+K+/uksACKvQyjM4hZgxrSe9FImXOBLhzbJWChHxMEm82UFeFM5MWrP2NcqdnCDojlZgyME++ACyJgxUxRPxxT8qpdNLDkhO5iZw2tgzHT1gMI5KMW96YOntDQ6dGfUO3lRcLgisVAo9rrlKQozHMIQWqgoKHt/cC1zd8GR171R0Nv0lJwOAlzngliblxzJ5fD9AOSncJiFt4K/dPz/g7oOeKCe5veQOtDmmt6k+gGCOsgw9nbhQ0nad/K/bb9GUhGkMiKejAyM+HH/TFtAfP7P9rqjbdtjxAEdAsmlxMtawilrTbwYEMCqOpZUtfhmaLW6AX+FASFhBjU/h6yVLkEl7eEzy1KiWl5mRI0cILZhaZecDVrAzQufeWSfdE6VXgB9Zix22p3Qrg52iwoNl01J9eJQ9Kc5C+TDnE6AS9RZjRAx0Ju9MpE8QdCJjlEsbIsII4gqIzUtmMCgASoAOO/WAcDxxQZ+Ei1yhr4er2Knmbw== astavie@satellite"
    ];

    # nvidia with modes for dual monitors
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    services.xserver.screenSection = ''
      Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
    '';

    # firmware
    hardware.enableRedistributableFirmware = true;
  }];

  backup.directories = [
    "/etc/ssh"
  ];
}
