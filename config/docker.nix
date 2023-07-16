{ lib, config, ... }:

with lib;
{
  options.docker.enable = mkEnableOption "docker";

  config.modules = mkIf config.docker.enable [{
    virtualisation.docker.enable = true;
    users.extraGroups.docker.members = config.superusers;
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  }];
}
