{ config, ... }:

{
  fileSystems."/".device = "/dev/disk/by-label/nixos";
}
