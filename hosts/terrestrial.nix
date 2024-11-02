{ pkgs, config, ... }:

{
  imports = [
    # base config
    ../shared
  ];

  networking.hostName = "terrestrial";
  networking.hostId = "93ad32f0";

  users.users.astavie = {
    password = "admin"; # TODO
    extraGroups = [ "wheel" "networkmanager" "dialout" ];
    isNormalUser = true;
  };

  asta = {
    impermanence.enable = true;
    xserver.enable = true;
    pipewire.enable = true;
    networking.enable = true;

    backup.directories = [
      "/etc/ssh"
    ];

    users.astavie = {
      ssh.enable = true;
      steam.enable = true;
      vbhost.enable = true;

      modules = [
        {
          home.packages = with pkgs; [
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
            peek
            obsidian

            gimp
            krita
            inkscape

            popcorntime
            vlc

            godot_4
            jetbrains.idea-community
            jetbrains.rider

            dotnet-sdk_7

            kdenlive
            ffmpeg
            audacity

            minecraftia
            corefonts

            # games
            ckan
          ];

          programs.git = {
            userEmail = "astavie@pm.me";
            userName = "Astavie";
          };

          asta.backup.directories = [
            "obsidian/.config/obsidian"
            "xfce/.config/xfce4"
            "xfce/Desktop"
            "fonts/.local/share/fonts"
          ];
        }
        ../home/desktop-chicago95.nix
        ../home/discord.nix
        ../home/zen.nix
        ../home/git.nix
        ../home/shell.nix
        ../home/minecraft.nix
        ../home/music.nix
        ../home/obs.nix
      ];
    };
  };

  programs.nix-ld.enable = true;

  # musnix
  musnix.enable = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "amdgpu" ];

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

  # xfce
  services.xserver = {
    enable = true;
    wacom.enable = true;
    videoDrivers = [ "amdgpu" ];
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = "xfce";

  environment.systemPackages = with pkgs; [
    xfce.xfce4-whiskermenu-plugin
  ];

  # firmware
  hardware.enableRedistributableFirmware = true;
}
