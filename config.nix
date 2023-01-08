let
  users.astavie = {
    superuser = true;
    packages = pkgs: with pkgs; [
      torrential
      neofetch
      helvum
      gimp
      pavucontrol
      htop
      teams
      unzip
      gnumake
    ];

    specialArgs.ssh-keygen = true;

    modules = [
      ./modules/home/coding.nix
      ./modules/home/desktop.nix
      ./modules/home/discord.nix
      ./modules/home/firefox.nix
      ./modules/home/git.nix
      ./modules/home/music.nix
      ./modules/home/shell.nix
      ./modules/home/steam.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ];
  };
in
{
  systems = {
    terrestrial = {
      hostid = "93ad32f0";
      system = "x86_64-linux";
      stateVersion = "22.11";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/nvidia.nix
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/pipewire.nix
        ./modules/system/ssh.nix
        ./modules/system/steam.nix
        ./modules/system/xserver.nix
        ./modules/system/vbhost.nix
      ];
    };
    vb = {
      hostid = "85dd8e44";
      system = "x86_64-linux";
      stateVersion = "22.11";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/vb.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/pipewire.nix
        ./modules/system/xserver.nix
      ];
    };
  };
}
