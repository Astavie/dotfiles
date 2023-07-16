{ lib, config, ... }:

with lib;
{
  options.xserver.enable = mkEnableOption "xserver";

  config.modules = mkIf config.xserver.enable [{
    services.xserver.enable = true;
    services.xserver.libinput.enable = true;
    services.xserver.displayManager.sx.enable = true;
    services.xserver.wacom.enable = true;
  }];
}
