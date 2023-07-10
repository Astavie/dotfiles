{ ... }:

{
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  hardware.steam-hardware.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
}
