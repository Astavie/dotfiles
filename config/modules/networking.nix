{ lib, config, ... }:

{
  options.asta = {
    networking.enable = lib.mkEnableOption "networking";
  };

  config = lib.mkIf config.asta.networking.enable {
    # avahi
    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.openFirewall = true;

    # zerotierone
    services.zerotierone.enable = true;
    asta.backup.directories = [
      "/var/lib/zerotier-one"
    ];
  };
}
