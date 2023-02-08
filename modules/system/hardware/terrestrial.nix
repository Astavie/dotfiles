{ ... }:

{
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # opengl
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # modes for dual monitors
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
  '';
}
