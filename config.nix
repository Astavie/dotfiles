let
  users.astavie = {
    superuser = true;
    specialArgs.ssh-keygen = true;
    modules = [
      ./modules/home/base.nix
      ./modules/home/coding.nix
      ./modules/home/herbstluftwm.nix
      ./modules/home/discord.nix
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
      stateVersion = "22.05";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/hardware/nvidia.nix
        ./modules/system/base.nix
        ./modules/system/xserver.nix
        ./modules/system/steam.nix
      ];
    };
    vb = {
      hostid = "85dd8e44";
      system = "x86_64-linux";
      stateVersion = "22.05";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/vb.nix
        ./modules/system/xserver.nix
        ./modules/system/steam.nix
      ];
    };
  };
}
