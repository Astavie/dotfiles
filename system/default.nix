{
  # custom inputs
  users,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  flexInner = (dir: ''
    if [ "$EUID" -eq 0 ]
    then
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${dir}}
      ${lib.concatStrings (lib.mapAttrsToList (username: usercfg: ''
        sudo -u ${username} ${pkgs.home-manager}/bin/home-manager switch --flake ''${1:-${dir}}
      '') users)}
    else
      ${pkgs.home-manager}/bin/home-manager switch --flake ''${1:-${dir}}
    fi
  '');

  flexSrc = if inputs ? flakeDir then (flexInner inputs.flakeDir) else ''
    if [ $# -eq 0 ]
    then
      DIR=$(mktemp -d)
      trap 'rm -rf -- "$DIR"' EXIT
      chmod o=rx $DIR
      ${pkgs.nix}/bin/nix flake clone ${inputs.flakeRepo} --dest $DIR
    fi
    ${flexInner "$DIR"}
  '';

  flex = pkgs.writeShellScriptBin "flex" flexSrc;
in
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    neovim git neofetch flex
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Create user
  users.mutableUsers = false;

  users.users = lib.mapAttrs (username: usercfg: {
    home = usercfg.home or "/home/${username}";

    isNormalUser = true;
    password = usercfg.password;

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups = lib.mkIf (usercfg ? superuser && usercfg.superuser) [ "wheel" "networkmanager" ];
  }) users;

}
