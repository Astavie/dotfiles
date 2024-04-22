{ pkgs, ... }:

{
  hostname = "terrestrial";
  hostid = "93ad32f0";
  system = "x86_64-linux";
  stateVersion = "23.05";

  users = {
    astavie = {
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
        obsidian

        popcorntime
        vlc

        godot_4
        jetbrains.idea-community
      ];

      ssh.enable = true;

      modules = [
        ../home/desktop-chicago95.nix
        ../home/discord.nix
        ../home/firefox.nix
        ../home/git.nix
        ../home/shell.nix
        ../home/minecraft.nix
        ../home/music.nix
        ../home/music-player.nix
        ../home/obs.nix
        ../home/vr.nix
        {
          programs.git = {
            userEmail = "astavie@pm.me";
            userName = "Astavie";
          };
        }
      ];

      backup.directories = [
        "obsidian/.config/obsidian"
        "xfce/.config/xfce4"
      ];
    };
    streamer = {
      packages = with pkgs; [
        discord-screenaudio
      ];
      modules = [
        ../home/desktop-catppuccin.nix
        ../home/discord.nix
        ../home/firefox.nix
        ../home/shell.nix
        ../home/minecraft.nix
      ];
    };
  };

  impermanence.enable = true;
  steam.enable = true;
  vbhost.enable = true;
  docker.enable = true;

  xserver.enable = true;
  pipewire.enable = true;

  modules = let
    range = start: end: if start > end then [] else [ start ] ++ range (start + 1) end;
  in [({ config, ... }: {
    # musnix
    musnix.enable = true;

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];

    # avahi for wyvrn
    services.avahi.openFirewall = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;

    networking.firewall.allowedTCPPorts =
      # audio server
      [ 4656 ] ++
      # ALVR
      [ 9943 9944 ] ++
      # hats
      [ 53706 ] ++
      # crusader kings
      range 1630 1641 ++ [ 443 ];

    networking.firewall.allowedUDPPorts =
      # ds tunneling
      [ 29519 ] ++
      # ALVR
      [ 9943 9944 ] ++
      # hats
      [ 53706 ] ++
      # crusader kings
      range 1630 1641 ++ [ 443 ];

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

    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;

      package = let 
        rcu_patch = pkgs.fetchpatch {
          url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
          hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
        };
      in config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "535.154.05";
          sha256_64bit = "sha256-fpUGXKprgt6SYRDxSCemGXLrEsIA6GOinp+0eGbqqJg=";
          sha256_aarch64 = "sha256-G0/GiObf/BZMkzzET8HQjdIcvCSqB1uhsinro2HLK9k=";
          openSha256 = "sha256-wvRdHguGLxS0mR06P5Qi++pDJBCF8pJ8hr4T8O6TJIo=";
          settingsSha256 = "sha256-9wqoDEWY4I7weWW05F4igj1Gj9wjHsREFMztfEmqm10=";
          persistencedSha256 = "sha256-d0Q3Lk80JqkS1B54Mahu2yY/WocOqFFbZVBh+ToGhaE=";

          #version = "550.40.07";
          #sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
          #sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
          #openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
          #settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
          #persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

          patches = [ rcu_patch ];
       };
    };

    services.xserver = {
      enable = true;
      wacom.enable = true;
      videoDrivers = [ "nvidia" ];
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
      displayManager.defaultSession = "xfce";
    };

    environment.systemPackages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
    ];

    # firmware
    hardware.enableRedistributableFirmware = true;
  })];

  backup.directories = [
    "/etc/ssh"
  ];
}
