{ ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "nvidia"
  ];
}
