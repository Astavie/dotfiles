{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.sx.enable = true;
}
