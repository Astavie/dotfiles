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
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  fileSystems."/data" = {
    device = "nixos/safe/data";
    fsType = "zfs";
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
