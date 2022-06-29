{
  # custom inputs
  configurationRevision, stateVersion, username,
  
  # system inputs
  pkgs, ...
}:

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
  system.configurationRevision = configurationRevision;
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
    neovim git neofetch
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Create user
  users.mutableUsers = false;
  users.users.${username} = {
    isNormalUser = true;
    password = "";

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups  = [ "wheel" "networkmanager" ];
  };

  nix.settings.trusted-users = [ username ];
}

