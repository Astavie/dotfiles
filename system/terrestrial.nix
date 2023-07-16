{
  hostname = "terrestrial";
  hostid = "93ad32f0";
  system = "x86_64-linux";
  stateVersion = "23.05";

  users.astavie = {
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
      peek
      x11vnc

      # teams-for-linux
      # parsec-bin
    ];

    specialArgs.ssh-keygen = true;

    modules = [
      ../modules/home/desktop.nix
      ../modules/home/discord.nix
      ../modules/home/firefox.nix
      ../modules/home/git.nix
      ../modules/home/shell.nix
      ../modules/home/steam.nix
      ../modules/home/minecraft.nix
      ../modules/home/music.nix
      ../modules/home/vr.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ];
  };
  impermanence.enable = true;

  modules = [
    ../modules/system/hardware/terrestrial.nix
    ../modules/system/hardware/uefi.nix
    ../modules/system/hardware/zfs.nix
    ../modules/system/base.nix
    ../modules/system/flatpak.nix
    ../modules/system/pipewire.nix
    ../modules/system/ssh.nix
    ../modules/system/steam.nix
    ../modules/system/xserver.nix
    ../modules/system/vbhost.nix
  ];

  sharedModules = [
    ../modules/home/pipewire.nix
  ];
}
