{ self, stateVersion, config, pkgs, lib, ... }:

{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # # Specify the linux kernel 
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_18;
  
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Let 'nixos-version --json' know about the Git revision
  # of this flake.
  system.configurationRevision = lib.mkIf (self ? rev) self.rev;
  system.stateVersion = stateVersion;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    neovim git nixos-option home-manager
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";

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
}

