{
  # custom inputs
  users, hostname, flakedir,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  # system package
  rehome = pkgs.writeShellScriptBin "rehome" (
    builtins.concatStringsSep "\n" ([''
      set -e
      if [ "$EUID" -ne 0 ]
      then
        exec sudo "$0"
      fi
    ''] ++ lib.mapAttrsToList (username: usercfg:
      let
        datadir = usercfg.data or "/data/${username}";
      in ''
        mkdir -m 700 -p ${datadir}
        chown ${username} ${datadir}
        ${pkgs.nix}/bin/nix build "''${1:-${flakedir}}#homeConfigurations.${username}@${hostname}.activationPackage" --out-link ${datadir}/generation
      ''
    ) users)
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
  flex = (datadir: pkgs.writeShellScriptBin "flex" ''
    ${overflex}
    ${pkgs.nix}/bin/nix build "''${1:-${flakedir}}#homeConfigurations.$USER@${hostname}.activationPackage" --out-link ${datadir}/generation
    ${datadir}/generation/activate
  '');
  flex-rebuild = (datadir: pkgs.writeShellScriptBin "flex-rebuild" ''
    ${overflex}
    sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakedir}}
    sudo ${rehome}/bin/rehome ''${1:-${flakedir}}
    ${datadir}/generation/activate
  '');
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
    neovim git neofetch rehome
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
  
    packages = let
      datadir = usercfg.data or "/data/${username}";
    in [
      (flex-rebuild datadir)
      (flex         datadir)
    ];
  }) users;

  users.extraUsers.root.password = "tmp";

  nix.settings.trusted-users = lib.attrNames (
    lib.filterAttrs (_: usercfg:
      usercfg ? superuser && usercfg.superuser
    ) users
  );

  # file with a list of users
  # environment.etc."users".text =
  #   builtins.concatStringsSep "\n" ((builtins.attrNames users) ++ [""]);

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

          datadir = usercfg.data or "/data/${username}";
        in "${setupEnv} ${datadir}/generation";
      };
    }
  ) users;

}
