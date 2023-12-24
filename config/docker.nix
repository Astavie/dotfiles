{ lib, config, pkgs, ... }:

with lib;
{
  options.docker.enable = mkEnableOption "docker";

  config.modules = mkIf config.docker.enable [{
    virtualisation.docker.enable = true;
    virtualisation.podman.enable = true;
    environment.systemPackages = [ pkgs.docker-compose ];

    users.extraGroups.docker.members = config.superusers;
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  }];
}
