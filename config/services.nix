{
  # NOTE: make options for these?
  modules = [{
    programs.dconf.enable = true;
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.avahi.openFirewall = true;
    services.zerotierone.enable = true;
  }];
  backup.directories = [
    "/var/lib/zerotier-one"
  ];
}
