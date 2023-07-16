{
  hostname = "vb";
  hostid = "85dd8e44";
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
    ];

    specialArgs.ssh-keygen = true;

    modules = [
      ../modules/home/desktop.nix
      ../modules/home/discord.nix
      ../modules/home/firefox.nix
      ../modules/home/git.nix
      ../modules/home/shell.nix
      ../modules/home/steam.nix
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
    ../modules/system/hardware/vb.nix
    ../modules/system/hardware/uefi.nix
    ../modules/system/hardware/zfs.nix
    ../modules/system/base.nix
    ../modules/system/pipewire.nix
    ../modules/system/xserver.nix
  ];

  sharedModules = [
    ../modules/home/pipewire.nix
  ];
}
