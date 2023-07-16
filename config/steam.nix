{ lib, config, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
in
{
  options = {
    steam.enable = mkEnableOption "steam";

    users = subset {
      backup.directories = mkIf config.steam.enable [
        {
          directory = "steam/.steam";
          method = "symlink";
        }
        {
          directory = "steam/.local/share/Steam";
          method = "symlink";
        }

        # Game specific directories
        "factorio/.factorio"
      ];
    };
  };
  config = {
    modules = mkIf config.steam.enable [{
      programs.steam.enable = true;
      programs.steam.remotePlay.openFirewall = true;
      hardware.steam-hardware.enable = true;
      hardware.opengl.enable = true;
      hardware.opengl.driSupport = true;
      hardware.opengl.driSupport32Bit = true;
    }];
  };
}
