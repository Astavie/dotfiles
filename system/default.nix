{
  # custom inputs
  users,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  flakeDir' = if inputs ? flakeDir then inputs.flakeDir else ./..;
  flex = pkgs.writeShellScriptBin "flex" ''
    if [ "$EUID" -eq 0 ]
    then
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakeDir'}}
      while read user; do
        sudo -u "''${user}" flex
      done < /etc/users
    else
      ${pkgs.home-manager}/bin/home-manager switch --flake ''${1:-${flakeDir'}}
    fi
  '';
                                in
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

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

  users.extraUsers.root.password = "tmp";

  nix.settings.trusted-users = lib.attrNames (
    lib.filterAttrs (_: usercfg:
      usercfg ? superuser && usercfg.superuser
    ) users
  );

  # file with a list of users
  environment.etc."users".text =
    builtins.concatStringsSep "\n" (builtins.attrNames users);

}
