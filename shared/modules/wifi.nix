{ lib, config, ... }:

{
  config = lib.mkIf (config.asta.networking.enable && config.asta.hardware.laptop) {
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "wpa_supplicant";
    asta.backup.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
