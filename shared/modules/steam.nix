{ lib, config, ... }:

let
  subset = module: lib.mkOption {
    type = with lib.types; attrsOf (submodule module);
  };
  steam-users = lib.filterAttrs (_: cfg: cfg.steam.enable) config.asta.users;
in
{
  options.asta.users = subset (u: {
    options = {
      steam.enable = lib.mkEnableOption "steam";
    };
    config = lib.mkIf u.config.steam.enable {
      modules = [{
        asta.backup.directories = [
          {
            directory = "steam/.steam";
            method = "symlink";
          }
          {
            directory = "steam/.local/share/Steam";
            method = "symlink";
          }
          "steam/.local/share/icons"
          "steam/.local/share/vulkan"

          # Game specific directories
          "factorio/.factorio"
          "paradox/.paradoxlauncher"
          "paradox/.local/share/Paradox Interactive"
        ];
      }];
    };
  });

  config = lib.mkIf (steam-users != {}) {
    programs.steam.enable = true;
    programs.steam.remotePlay.openFirewall = true;
    hardware.steam-hardware.enable = true;
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;

    # remote play / vr streaming
    networking.firewall.allowedTCPPorts = [ 27036 27037 ];
    networking.firewall.allowedUDPPorts = [ 27031 27036 10400 10401 ];
  };
}
