{ ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "nvidia"
  ];
}
