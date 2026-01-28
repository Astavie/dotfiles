{ pkgs, lib, ... }:

let
  patchDesktop = pkg: appName: from: to: lib.hiPrio (
    pkgs.runCommand "$patched-desktop-entry-for-${appName}" {} ''
      ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
      ${pkgs.coreutils}/bin/cp -r ${pkg}/share/icons $out/share/icons
      ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ${pkgs.gnused}/bin/sed -i '/^TryExec/d' $out/share/applications/${appName}.desktop
      '');
  GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
in
{
  imports = [
    # base config
    ../shared
  ];

  networking.hostName = "newhorizons";
  networking.hostId = "92e8a3c2";

  users.users.astavie = {
    password = "admin"; # TODO
    extraGroups = [ "wheel" "networkmanager" "dialout" ];
    isNormalUser = true;
  };

  asta = {
    impermanence.enable = true;
    xserver.enable = true;
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
      vbhost.enable = true;
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
            jujutsu
            (GPUOffloadApp unityhub "unityhub")
          ];

          home.file.".local/share/fonts/truetype/Minecraftia-Regular.ttf".source = ../res/Minecraftia-Regular.ttf;

          programs.git.settings.user = {
            email = "astavie@pm.me";
            name = "Astavie";
          };

          asta.backup.directories = [
            "unity3d/.config/unity3d"
            "unity3d/.config/unityhub"
            "unity3d/Unity"
          ];

          # programs.hyprlock.enable = true;
          # wayland.windowManager.hyprland.settings.bind = [
          #   "$mod, L, exec, hyprlock"
          # ];
        }
        ../home/desktop-hyprland.nix
        ../home/theme-catppuccin.nix
        ../home/discord.nix
        ../home/zen.nix
        ../home/git.nix
        ../home/shell.nix
        ../home/music.nix
      ];
    };
  };

  # some other stuff
  programs.nix-ld.enable = true;

  musnix.enable = true;

  # security.pam.services.hyprlock = {};
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # nvidia
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # cpu
  hardware.cpu.intel.updateMicrocode = true;

  # graphics
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # firmware
  hardware.enableRedistributableFirmware = true;
}
