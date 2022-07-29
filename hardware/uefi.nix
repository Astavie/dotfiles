{ ... }:

{
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };
  boot.loader.systemd-boot.enable = true;
}
