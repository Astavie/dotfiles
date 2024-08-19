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
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
  };
}
