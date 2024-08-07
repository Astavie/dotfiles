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

        # games
        ckan
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
        ../home/obs.nix
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
        "xfce/Desktop"
      ];
    };
  };

  impermanence.enable = true;
  steam.enable = true;
  vbhost.enable = true;

  xserver.enable = true;
  pipewire.enable = true;

  modules = [({ config, ... }: {
    # musnix
    musnix.enable = true;

    boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" "amdgpu" ];

    networking.firewall.allowedTCPPorts =
      # ALVR
      [ 9943 9944 ];

    networking.firewall.allowedUDPPorts =
      # ALVR
      [ 9943 9944 ];

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

    # hardware.opengl.extraPackages = with pkgs; [
    #   amdvlk
    # ];
    hardware.opengl.extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];

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
  })];

  backup.directories = [
    "/etc/ssh"
  ];
}
