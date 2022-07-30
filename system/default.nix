{
  # custom inputs
  users,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  flakeDir' = if inputs ? flakeDir then inputs.flakeDir else ./..;
  flex-build = pkgs.writeShellScriptBin "flex-build" ''
    while read user; do
      mkdir -m 700 -p /data/$user
      chown $user /data/$user
      ${pkgs.nix}/bin/nix build "''${1:-${flakeDir'}}#homeConfigurations.$user@$(hostname).activationPackage" --out-link /data/$user/generation
    done < /etc/users
  '';
  flex = pkgs.writeShellScriptBin "flex" ''
    if [ "$EUID" -eq 0 ]
    then
      ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakeDir'}}
      ${flex-build}/bin/flex-build
    else
      ${pkgs.nix}/bin/nix build "''${1:-${flakeDir'}}#homeConfigurations.$USER@$(hostname).activationPackage" --out-link /data/$USER/generation
      /data/$USER/generation/activate
    fi
  '';
                                in
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    neovim git neofetch flex flex-build
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
    builtins.concatStringsSep "\n" ((builtins.attrNames users) ++ [""]);

  # activate home manager on startup
  # copied from https://github.com/nix-community/home-manager/blob/master/nixos/default.nix
  systemd.services = lib.mapAttrs' (username: usercfg:
    lib.nameValuePair ("home-manager-${utils.escapeSystemdPath username}") {
      description = "Home Manager environment for ${username}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nix-daemon.socket" ];
      after = [ "nix-daemon.socket" ];
      before = [ "systemd-user-sessions.service" ];

      environment = {};

      unitConfig = { RequiresMountsFor = usercfg.home or "/home/${username}"; };

      stopIfChanged = false;

      serviceConfig = {
        User = username;
        Type = "oneshot";
        RemainAfterExit = "yes";
        TimeoutStartSec = 90;
        SyslogIdentifier = "hm-activate-${username}";

        ExecStart = let
          systemctl =
            "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";
          
          sed = "${pkgs.gnused}/bin/sed";

          exportedSystemdVariables = lib.concatStringsSep "|" [
            "DBUS_SESSION_BUS_ADDRESS"
            "DISPLAY"
            "WAYLAND_DISPLAY"
            "XAUTHORITY"
            "XDG_RUNTIME_DIR"
          ];

          setupEnv = pkgs.writeScript "hm-setup-env" ''
            #! ${pkgs.runtimeShell} -el

            eval "(
              ${systemctl} --user show-environment 2> /dev/null \
              | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
            )"

            exec "$1/activate"
          '';
        in "${setupEnv} /data/${username}/generation";
      };
    }
  ) users;

}
