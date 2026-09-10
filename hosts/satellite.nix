{ lib, config, pkgs, ... }:

{
  imports = [
    # base config
    ../shared
    # chromebook stuff
    {
      # from https://github.com/jmbaur/homelab/blob/bfd82fb4657aa7ff0d62898b383655ca75a39cfc/nixos-modules/hardware/google-asurada-spherion/default.nix
      hardware.enableRedistributableFirmware = true;
      hardware.deviceTree.name = "mediatek/mt8192-asurada-spherion-r0.dtb";
      boot.kernelParams = [
        "console=ttyS0,115200"
        "console=tty1"
      ];
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

    hardware = {
      battery = true;
      laptop = true;
      monitors = [{
        portname = "eDP-1";
        width = 1920;
        height = 1080;
      }];
    };

    users.astavie = {
      ssh.enable = true;

      modules = [
        ({ config, ... }: {
          # home.packages = with pkgs; [];

          home.file.".local/share/fonts/truetype/Minecraftia-Regular.ttf".source = ../res/Minecraftia-Regular.ttf;
          home.file."data".source = config.lib.file.mkOutOfStoreSymlink /data/astavie;

          programs.git.settings.user = {
            email = "astavie@pm.me";
            name = "Astavie";
          };
        })
        ../home/desktop-hyprland.nix
        ../home/theme-catppuccin.nix
        ../home/discord.nix
        ../home/zen.nix
        ../home/git.nix
        ../home/shell.nix
      ];
    };
  };

  # some other stuff
  programs.nix-ld.enable = true;
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

  # drivers / firmware
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
}
