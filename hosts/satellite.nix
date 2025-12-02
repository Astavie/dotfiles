{ pkgs, inputs, ... }:

{
  imports = [
    # base config
    ../shared
    # chromebook stuff
    inputs.cros.nixosModules.default
    inputs.cros.nixosModules.crosAarch64
    {
      boot.kernelParams = [ "console=tty0" ];
      boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux_cros_latest;
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
    pipewire.enable = true;
    networking.enable = true;

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
}
