{ lib, config, ... }:

lib.module config "steam" {
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
} {
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  hardware.steam-hardware.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # remote play / vr streaming
  networking.firewall.allowedTCPPorts = [ 27036 27037 ];
  networking.firewall.allowedUDPPorts = [ 27031 27036 10400 10401 ];
}
