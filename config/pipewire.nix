{ lib, config, pkgs, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
in
{
  options = {
    pipewire.enable = mkEnableOption "pipewire";

    users = subset {
      modules = mkIf config.pipewire.enable [{
        services.easyeffects = {
          enable = true;
        };
      }];
      backup.directories = mkIf config.pipewire.enable [
        "pipewire/.local/state/wireplumber"
        "easyeffects/.config/easyeffects"
      ];
      packages = mkIf config.pipewire.enable (with pkgs; [
        pavucontrol
        helvum
      ]);
    };
  };
  config = {
    modules = mkIf config.pipewire.enable [{
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };
    }];
  };
}
