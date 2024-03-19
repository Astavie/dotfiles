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
      hyprland.enable = true;

      modules = [
        ../home/desktop-glassmorphism.nix
        ../home/discord.nix
        ../home/firefox.nix
        ../home/git.nix
        ../home/shell.nix
        ../home/minecraft.nix
        ../home/music.nix
        ../home/music-player.nix
        ../home/vr.nix
        {
          programs.git = {
            userEmail = "astavie@pm.me";
            userName = "Astavie";
          };
        }
      ];

      backup.directories = ["obsidian/.config/obsidian"];
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

    # NVIDIA has flickering issues on xwayland since 545, so we downgrade to 535
    hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];

    # services.xserver.screenSection = ''
    #   Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
    # '';

    # firmware
    hardware.enableRedistributableFirmware = true;
  })];

  backup.directories = [
    "/etc/ssh"
  ];
}
