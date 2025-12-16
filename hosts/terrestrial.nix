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

    hardware = {
      monitors = [{
        portname = "DP-1";
        scale = 2.0;
        width = 3840;
        height = 2160;
        # refreshRate = 144;
      }];
    };

    users.astavie = {
      ssh.enable = true;
      steam.enable = true;
      wivrn.enable = true;
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
            obsidian
            gimp
            krita
            inkscape
            popcorntime
            vlc
            kdePackages.kdenlive
            ffmpeg
            audacity

            # fonts
            # minecraftia
            corefonts
            aegyptus

            # games
            ckan
            osu-lazer-bin
          ];

          home.file.".local/share/fonts/truetype/Minecraftia-Regular.ttf".source = ../res/Minecraftia-Regular.ttf;

          programs.git.settings.user = {
            email = "astavie@pm.me";
            name = "Astavie";
          };

          asta.backup.directories = [
            "obsidian/.config/obsidian"
            "xfce/.config/xfce4"
            "xfce/Desktop"
            "fonts/.local/share/fonts"
            "osu/.local/share/osu"
          ];
        }
        ../home/desktop-hyprland.nix
        ../home/theme-catppuccin.nix
        ../home/discord.nix
        ../home/zen.nix
        ../home/git.nix
        ../home/shell.nix
        ../home/minecraft.nix
        ../home/music.nix
        ../home/obs.nix
        ../home/stuck.nix
        ../home/libtas.nix
        ../home/godot.nix
      ];
    };
  };

  # some other stuff
  networking.interfaces."enp4s0".wakeOnLan.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  programs.nix-ld.enable = true;

  musnix.enable = true;

  boot.zfs.package = pkgs.zfs_unstable;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnh8AZ6+xv0lnHot3w4L4vAogsgHryRBTsF7kb/ivgl astavie@penguin"
  ];

  # firmware
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
