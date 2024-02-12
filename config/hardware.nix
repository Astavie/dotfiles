{ lib, config, ... }:

with lib;
{
  options = {
    boot.mode = mkOption {
      type = types.enum [ "uefi" ];
      default = "uefi";
    };
    boot.fs = mkOption {
      type = types.enum [ "zfs" ];
      default = "zfs";
    };
  };
  config = {
    modules =
      optional (config.boot.mode == "uefi") {

        fileSystems."/boot" = {
          device = "/dev/disk/by-label/boot";
          fsType = "vfat";
        };
        swapDevices = [{
          device = "/dev/disk/by-label/swap";
        }];

        boot.loader.systemd-boot.enable = true;
        boot.loader.systemd-boot.configurationLimit = 20;

      } ++
      optional (config.boot.fs == "zfs") {

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

      };
  };
}
