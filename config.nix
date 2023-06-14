let
  astavie = full: {
    superuser = true;
    packages = pkgs: with pkgs; [
      # base
      pavucontrol
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
      teams-for-linux
      parsec-bin
      peek
    ] ++ (if full then [
      # custom packages for terrestrial
      x11vnc
    ] else [
      # custom packages for satellite
      networkmanagerapplet
      turbovnc

      vscode
      docker
      docker-compose
    ]);

    specialArgs.ssh-keygen = true;

    modules = [
      ./modules/home/desktop.nix
      ./modules/home/discord.nix
      ./modules/home/firefox.nix
      ./modules/home/git.nix
      ./modules/home/shell.nix
      ./modules/home/steam.nix
      ./modules/home/coding.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ] ++ (if full then [
      # custom modules for terrestrial
      ./modules/home/music.nix
      ./modules/home/vr.nix
      ./modules/home/minecraft-dev.nix
      ./modules/home/minecraft.nix
    ] else [
      # custom modules for satellite
      ./modules/home/music.nix
    ]);
  };
in
{
  systems = {
    terrestrial = {
      hostid = "93ad32f0";
      system = "x86_64-linux";
      stateVersion = "23.05";

      users = {
        astavie = astavie true;
      };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/terrestrial.nix
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/flatpak.nix
        ./modules/system/pipewire.nix
        ./modules/system/ssh.nix
        ./modules/system/steam.nix
        ./modules/system/xserver.nix
        ./modules/system/vbhost.nix
      ];

      sharedModules = [
        ./modules/home/pipewire.nix
      ];
    };
    satellite = {
      hostid = "92e8a3c2";
      system = "x86_64-linux";
      stateVersion = "23.05";

      users = {
        astavie = astavie false;
      };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/satellite.nix
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/docker.nix
        ./modules/system/flatpak.nix
        ./modules/system/pipewire.nix
        ./modules/system/ssh.nix
        ./modules/system/steam.nix
        ./modules/system/xserver.nix
      ];

      sharedModules = [
        ./modules/home/pipewire.nix
      ];
    };
    vb = {
      hostid = "85dd8e44";
      system = "x86_64-linux";
      stateVersion = "23.05";

      users = {
        astavie = astavie false;
      };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/vb.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/pipewire.nix
        ./modules/system/xserver.nix
      ];

      sharedModules = [
        ./modules/home/pipewire.nix
      ];
    };
  };
}
