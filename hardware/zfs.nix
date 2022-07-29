{ lib, ... }:

{
  fileSystems."/" = {
    device = "nixos/local/root";
    fsType = "zfs";
  };
  fileSystems."/nix" = {
    device = "nixos/local/nix";
    fsType = "zfs";
  };
  fileSystems."/data" = {
    device = "nixos/safe/data";
    fsType = "zfs";
    options = [ "mode=777" ];
  };
  
  boot.kernelParams = [ "elevator=none" "nohibernate" ];
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r nixos/local/root@blank
  '';

  services.zfs = {
    autoScrub.enable = true;
    # TODO: autoSnapshot, autoReplication
  };
}
