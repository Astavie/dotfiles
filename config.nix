let
  users.astavie = {
    superuser = true;
    specialArgs.ssh-keygen = true;
    modules = [
      ./modules/home/base.nix
      ./modules/home/coding.nix
      ./modules/home/stumpwm.nix
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
  systems.vb = {
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
    ];
  };
}
