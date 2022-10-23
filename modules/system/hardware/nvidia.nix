{ ... }:

{
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # modes for dual monitors
  services.xserver.screenSection = ''
    Option "metamodes" "nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }, nvidia-auto-select { ForceCompositionPipeline = On, ForceFullCompositionPipeline=On, AllowGSYNCCompatible=On }"
  '';
}
