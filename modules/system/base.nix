{
  # custom inputs
  users, hostname, impermanence,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  sudo = "doas";

  # system package
  rehome = pkgs.writeShellScriptBin "rehome" (
    builtins.concatStringsSep "\n" ([''
      set -e
      if [ "$EUID" -ne 0 ]
      then
        exec ${sudo} "$0"
      fi
    ''] ++ lib.mapAttrsToList (username: usercfg: ''
      mkdir -m 700 -p ${usercfg.dir.data}
      chown ${username} ${usercfg.dir.data}
      mkdir -m 700 -p ${usercfg.dir.persist}
      chown ${username} ${usercfg.dir.persist}
      ${pkgs.nix}/bin/nix build "''${1:-.}#homeConfigurations.${username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation --print-build-logs
    '') users)
  );

  # user packages
  overflex = ''
    set -e
    if [ "$EUID" -eq 0 ]
    then
      echo "you're flexing too hard"
      exit
    fi
  '';
  flex = (username: usercfg: pkgs.writeShellScriptBin "flex" ''
    ${overflex}
    ${pkgs.nix}/bin/nix build "''${1:-.}#homeConfigurations.${username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation --print-build-logs
    ${usercfg.dir.persist}/generation/activate
  '');
  sup = (username: usercfg: pkgs.writeShellScriptBin "sup" ''
    ${overflex}
    ${sudo} mkdir -m 700 -p ${impermanence.dir}
    ${sudo} ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-.}
    ${sudo} ${rehome}/bin/rehome ''${1:-.}
    ${usercfg.dir.persist}/generation/activate
  '');
in
{
  # Reasonable defaults
  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  programs.dconf.enable = true;

  # Binary Cache for Haskell.nix
  nix.settings.trusted-public-keys = [
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
  ];
  nix.settings.substituters = [
    "https://cache.iog.io"
  ];

  # Pick doas or sudo
  security.sudo.enable = sudo == "sudo";
  security.doas.enable = sudo == "doas";
  postinstall.sudo = sudo;

  # Create users
  environment.systemPackages = [ rehome pkgs.git ];
  
  users.mutableUsers = false;
  users.users = builtins.mapAttrs (username: usercfg: {
    home = usercfg.dir.home;

    isNormalUser = true;
    password = ""; # TODO

    # Use fish shell
    shell = pkgs.fish;

    extraGroups = [ "audio" "video" ] ++ lib.optionals usercfg.superuser [ "wheel" "networkmanager" ];

    packages = [
      (sup  username usercfg)
      (flex username usercfg)
    ];
  }) users;

  nix.settings.trusted-users = builtins.attrNames (lib.filterAttrs (_: usercfg: usercfg.superuser) users);

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

      unitConfig = { RequiresMountsFor = usercfg.dir.home; };

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
        in "${setupEnv} ${usercfg.dir.persist}/generation";
      };
    }
  ) users;

}
