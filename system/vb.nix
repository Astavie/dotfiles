{ pkgs, config, ... }:

{
  hostname = "vb";
  hostid = "85dd8e44";
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
    ];

    ssh.enable = true;

    modules = [
      ../home/desktop.nix
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

  xserver.enable = true;
  pipewire.enable = true;

  modules = [{
    virtualisation.virtualbox.guest.enable = true;
    users.extraGroups.vboxsf.members = config.superusers;
  }];
}
