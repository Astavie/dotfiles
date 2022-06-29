# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_18;
  
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = with inputs; lib.mkIf (self ? rev) self.rev;
  system.stateVersion = "22.05";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Set password for 'root'
  users.users.root.password = "";

  # Create user 'astavie'
  users.mutableUsers = false;
  users.users."astavie" = {
    isNormalUser = true;
    description = "Astavie";
    password = "";

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups  = [ "wheel" "networkmanager" ];
  };

  nix.settings.trusted-users = [ "astavie" ];

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    neovim git nixos-option
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";
}

