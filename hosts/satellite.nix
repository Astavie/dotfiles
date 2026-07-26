{ lib, config, pkgs, ... }:

{
  imports = [
    # base config
    ../shared
    # chromebook stuff
    {
      # from https://github.com/jmbaur/homelab/blob/bfd82fb4657aa7ff0d62898b383655ca75a39cfc/nixos-modules/hardware/google-asurada-spherion/default.nix
      hardware.enableRedistributableFirmware = true;
      # hardware.deviceTree.name = "mediatek/mt8192-asurada-spherion-r0.dtb";
      # boot.kernelParams = [
      #   "console=ttyS0,115200"
      #   "console=tty1"
      # ];
      boot.initrd.availableKernelModules = [
        "uas"
        "sd_mod"
      # from https://github.com/jmbaur/homelab/blob/bfd82fb4657aa7ff0d62898b383655ca75a39cfc/nixos-modules/hardware/chromebook/default.nix
        "tpm_tis_spi"
      ];
      boot.kernelPatches = [
        {
          name = "google-firmware";
          patch = null;
          structuredExtraConfig.GOOGLE_FIRMWARE = lib.kernel.yes;
        }
      ];
      services.udev.packages = [
        (pkgs.runCommand "chromiumos-autosuspend-udev-rules" { } ''
          mkdir -p $out/lib/udev/rules.d
          ${lib.getExe pkgs.buildPackages.python3} \
            ${config.systemd.package.src}/tools/chromiumos/gen_autosuspend_rules.py \
            >$out/lib/udev/rules.d/01-chromium-autosuspend.rules
        '')
      ];
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

  # kernel
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.zfs.package = pkgs.zfs_2_4;
}
