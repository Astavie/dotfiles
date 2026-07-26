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
    pipewire.enable = true;
    networking.enable = true;
    timekpr.enable = true;

    backup.directories = [
      "/etc/ssh"
      "/etc/lact"
    ];

    hardware = {
      mouse = true;
      monitors = [{
        portname = "DP-1";
        scale = 2.0;
        width = 3840;
        height = 2160;
        refreshRate = 144;
      }];
    };

    users.astavie = {
      ssh.enable = true;
      steam.enable = true;
      wivrn.enable = true;
      vbhost.enable = true;

      modules = [
        ({ config, ... }: {
          home.packages = with pkgs; [
            # apps
            obsidian
            gimp
            krita
            unstable.pixieditor
            inkscape
            popcorntime
            vlc
            kdePackages.kdenlive
            ffmpeg
            audacity

            # ide
            javaPackages.compiler.openjdk17
            jetbrains.idea

            # fonts
            # minecraftia
            corefonts
            aegyptus

            # games
            ckan
            unstable.osu-lazer-bin
          ];

          home.file.".local/share/fonts/truetype/Minecraftia-Regular.ttf".source = ../res/Minecraftia-Regular.ttf;
          home.file."data".source = config.lib.file.mkOutOfStoreSymlink /data/astavie;

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
        })
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
        ../home/zed.nix
      ];
    };
  };

  # yay firewall
  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];
  networking.firewall.allowedTCPPorts = [ 7236 7250 ];
  networking.firewall.allowedUDPPorts = [ 7236 5353 ];

  # some other stuff
  networking.interfaces."enp4s0".wakeOnLan.enable = true;
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # common requirement for several games
    stdenv.cc.cc.lib

    # from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/games/steam/fhsenv.nix#L72-L79
    libxcomposite
    libxtst
    libxrandr
    libxext
    libx11
    libxfixes
    libGL
    libva

    # from https://github.com/NixOS/nixpkgs/blob/nixos-23.05/pkgs/games/steam/fhsenv.nix#L124-L136
    fontconfig
    freetype
    libxt
    libxmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew_1_10
    libdrm
    libidn
    tbb
    zlib

    # and some extras from me
    libxcursor
    libxkbcommon
    libpulseaudio
    ffmpeg
  ];

  musnix.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.zfs.package = pkgs.zfs_2_4;

  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" "amdgpu" ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  services.lact.enable = true;

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
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP1ZcX+/Z6RahqdSGnLppj58Plq8CHfSyNeCAaCvAWIAzQBgXMGbY9pNVNvfiSbluadrPTri1JXU/eq3TYcFVkB1KWqQHmd1PLxv0g3MJSENha5w0KTn9w6HqoMOvNpj9hBo8XT7NuBoyiklhGAsM9d5jubLDYt2PAcA3B1yoNTm/hTs6yeSnJ6dgx+ypNClKgX90lhWW3PyLtr+KO/b/t255CY9jhcR0JDu7asUXwLOtLCokoLRjifsQIaqt0SJlG85XefmAlNR7kAwSZof7TY8FzofdiYTHQCwckQqztDGpkohJEtZLs2CHIYdf3KTQ/FHC//pcdoZCo8UqtV590o9JbIi/TyiXXqh3ZlCK1gfPkHngjTl8lp/9fXghsxqXDg71DCgjtOVWzVme2VG/Dd/RRrBJVZxkYyRw5XD0wX7tXseKZxUA21W2UB9aojUoQNh+PgLEzFuUnPDaz+TiEp8BI65QS6axUhvdNfMJaANfDmbYSOKK56p85ywZhO/OJcXrZCl407EmGrZj40aj11WxygJch9AUiDNERFMd6OpsNL1NP1t03AoR46yiXfWzQuMEN0daEOHPXbLUry9cAWrItKAnfDenEu3bOBH/yoQPkEhmPrljG6F0iYEd8kLB0QmnRO5fJdFWl+GRWqeu3XNDeVg+7Kgouh+9CizEnYQ== astavie@satellite"
  ];

  # firmware
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
}
