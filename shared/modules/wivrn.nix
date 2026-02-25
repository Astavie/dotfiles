{ lib, config, pkgs, ... }:

lib.module config "wivrn" {
  home.packages = with pkgs; [
    wlx-overlay-s
    wivrn
    monado
  ];
  home.file.".config/openxr/1/active_runtime.json".source =
    "${pkgs.monado}/share/openxr/1/openxr_monado.json";
  # asta.backup.directories = [
  #   "WiVRn/.config/wivrn"
  # ];
} {
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  networking.firewall.allowedTCPPorts = [ 9757 ];
  networking.firewall.allowedUDPPorts = [ 9757 5353 ];
}
