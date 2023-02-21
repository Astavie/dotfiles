{ ... }:

{
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # avahi for wyvrn
  services.avahi.enable = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  networking.firewall.allowedTCPPorts = [ 9757 9758 9759 ];
  networking.firewall.allowedUDPPorts = [ 9757 9758 9759 ];

  # ssh server
  services.openssh = {
    enable = true;
    forwardX11 = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
  };

  users.users."astavie".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYGOiKlp1ajqY3h1jQgLz/5Pq1enREmmQKsoKVrowYDnZEQ4KCB5RaI9b6Hp9FvVleaBb6u+vJvzFZWCC6yvlNzzddX2UwnrDYqWxmfXKtp+Bhs2nfOI8MyqyXyRYyUOz4wMDaUzlMio1rsCFT66wp61S/UvsncV6pzWQKKxJzI/hgMjwUhOdnhRFqymqA+K+/uksACKvQyjM4hZgxrSe9FImXOBLhzbJWChHxMEm82UFeFM5MWrP2NcqdnCDojlZgyME++ACyJgxUxRPxxT8qpdNLDkhO5iZw2tgzHT1gMI5KMW96YOntDQ6dGfUO3lRcLgisVAo9rrlKQozHMIQWqgoKHt/cC1zd8GR171R0Nv0lJwOAlzngliblxzJ5fD9AOSncJiFt4K/dPz/g7oOeKCe5veQOtDmmt6k+gGCOsgw9nbhQ0nad/K/bb9GUhGkMiKejAyM+HH/TFtAfP7P9rqjbdtjxAEdAsmlxMtawilrTbwYEMCqOpZUtfhmaLW6AX+FASFhBjU/h6yVLkEl7eEzy1KiWl5mRI0cILZhaZecDVrAzQufeWSfdE6VXgB9Zix22p3Qrg52iwoNl01J9eJQ9Kc5C+TDnE6AS9RZjRAx0Ju9MpE8QdCJjlEsbIsII4gqIzUtmMCgASoAOO/WAcDxxQZ+Ei1yhr4er2Knmbw== astavie@satellite"
  ];

  backup.directories = [
    "/etc/ssh"
  ];

  # opengl
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # modes for dual monitors
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
  '';
}
