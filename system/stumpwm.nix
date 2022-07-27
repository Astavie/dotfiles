{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.windowManager.stumpwm.enable = true;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xmodmap}/bin/xmodmap -e "clear mod4"
  '';
  
  environment.systemPackages = with pkgs; [
    xorg.xmodmap
  ];
}
