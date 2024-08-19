{ lib, config, ... }:

{
  options.asta = {
    xserver.enable = lib.mkEnableOption "xserver";
  };

  config = lib.mkIf config.asta.xserver.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.sx.enable = true;
    services.xserver.wacom.enable = true;
    services.libinput.enable = true;
  };
}
