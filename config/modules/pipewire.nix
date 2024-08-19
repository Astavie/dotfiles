{ pkgs, lib, config, ... }:

{
  options.asta = {
    pipewire.enable = lib.mkEnableOption "pipewire";
  };

  config = lib.mkIf config.asta.pipewire.enable {
    asta.modules = [{
      services.easyeffects = {
        enable = true;
      };
      asta.backup.directories = [
        "pipewire/.local/state/wireplumber"
        "easyeffects/.config/easyeffects"
      ];
      home.packages = with pkgs; [
        pavucontrol
        helvum
      ];
    }];

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
