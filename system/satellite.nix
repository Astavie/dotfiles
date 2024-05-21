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
      runelite
      obsidian
      desmume

      popcorntime
      vlc

      # teams-for-linux
      jetbrains.rider
      dotnet-sdk_7
    ];

    ssh.enable = true;

    modules = [
      ../home/desktop-catppuccin.nix
      ../home/discord.nix
      ../home/firefox.nix
      ../home/git.nix
      ../home/shell.nix
      ../home/minecraft.nix
      {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
      }
    ];

    backup.directories = [ 
      "runelite/.runelite"
      "obsidian/.config/obsidian"
    ];
  };

  impermanence.enable = true;
  steam.enable = true;
  vbhost.enable = true;
  docker.enable = true;

  xserver.enable = true;
  pipewire.enable = true;

  modules = [{
    # nvidia
    hardware.nvidia.modesetting.enable = true;
    services.xserver.videoDrivers = [ "nvidia" "intel" ];

    networking.firewall.allowedTCPPorts = [ 5900 ];
    networking.firewall.allowedUDPPorts = [ 5900 ];

    environment.systemPackages = [ nvidia-offload ];
    hardware.nvidia.prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # networking
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "wpa_supplicant";

    # cpu
    hardware.enableRedistributableFirmware = true;
    hardware.cpu.intel.updateMicrocode = true;
    # powerManagement.cpuFreqGovernor = "powersave";
  }];

  backup.directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
