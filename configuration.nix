# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  system.stateVersion = "22.05";

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

  # Create user 'astavie'
  users.mutableUsers = false;
  users.users."astavie" = {
    isNormalUser = true;
    home = "/home/astavie";
    description = "Astavie";

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups  = [ "wheel" "networkmanager" ];
  };

  # nix.settings.trusted-users = [ "astavie" ];

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    nvim git
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";
}

