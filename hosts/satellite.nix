{ pkgs, inputs, ... }:

{
  imports = [
    # base config
    ../shared
    # chromebook stuff
    inputs.cros.nixosModules.default
    inputs.cros.nixosModules.crosAarch64
    {
      boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_cros_latest.override {
        linux_latest = pkgs.unstable.linux_6_18;
      });
      boot.zfs.package = pkgs.unstable.zfs_2_4;
    }
  ];

  networking.hostName = "satellite";
  networking.hostId = "577d321b";

  users.users.astavie = {
    password = "admin"; # TODO
    extraGroups = [ "wheel" "networkmanager" "dialout" ];
    isNormalUser = true;
  };

  asta = {
    impermanence.enable = true;
    pipewire.enable = true;
    networking.enable = true;
    backup.directories = [
      "/etc/NetworkManager/system-connections"
    ];

    hardware = {
      battery = true;
      monitors = [{
        portname = "eDP-1";
        width = 1920;
        height = 1080;
      }];
    };

    users.astavie = {
      ssh.enable = true;

      modules = [
        {
          home.packages = with pkgs; [
            unzip
            gnumake
            neofetch
            htop
            sutils
            skim
            silver-searcher
          ];
          programs.git.settings.user = {
            email = "astavie@pm.me";
            name = "Astavie";
          };
        }
        ../home/desktop-hyprland.nix
        ../home/theme-catppuccin.nix
        ../home/discord.nix
        ../home/zen.nix
        ../home/git.nix
        ../home/shell.nix
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # drivers / firmware
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
}
