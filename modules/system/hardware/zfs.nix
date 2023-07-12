{ ... }:

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
  };
  fileSystems."/persist" = {
    device = "nixos/safe/persist";
    fsType = "zfs";
  };

  boot.kernelParams = [ "elevator=none" "nohibernate" ];

  services.zfs = {
    autoScrub.enable = true;
    # TODO: autoSnapshot, autoReplication
  };
}
