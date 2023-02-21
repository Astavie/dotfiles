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

  # opengl
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # modes for dual monitors
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
  '';
}
