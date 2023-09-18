{ pkgs, ... }:

let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  hostname = "satellite";
  hostid = "92e8a3c2";
  system = "x86_64-linux";
  stateVersion = "23.05";

  users.astavie = {
    superuser = true;
    packages = with pkgs; [
      # base
      pavucontrol
      unzip
      gnumake
      neofetch
      htop
      sutils
      skim
      silver-searcher

      # apps
      torrential
      gimp
      peek
      networkmanagerapplet
      turbovnc

      # teams-for-linux
      # parsec-bin
    ];

    ssh.enable = true;
    wireshark.enable = true;

    modules = [
      ../home/desktop-catppuccin.nix
      ../home/discord.nix
      ../home/firefox.nix
      ../home/git.nix
      ../home/shell.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ];
  };

  impermanence.enable = true;
  steam.enable = true;
  docker.enable = true;

  xserver.enable = true;
  pipewire.enable = true;

  modules = [{
    # nvidia
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" "intel" ];

    environment.systemPackages = [ nvidia-offload ];
    hardware.nvidia.prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # networking
    networking.networkmanager.enable = true;
    networking.wireless.iwd.enable = true;
    networking.networkmanager.wifi.backend = "iwd";

    # cpu
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
    powerManagement.cpuFreqGovernor = "powersave";
  }];

  backup.directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
