{
  # custom inputs
  users, hostname, flakedir,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  # list of users with ssh-keygen flag
  ssh-users = builtins.filter (usercfg: usercfg.ssh-keygen) users;

  # system package
  rehome = pkgs.writeShellScriptBin "rehome" (
    builtins.concatStringsSep "\n" ([''
      set -e
      if [ "$EUID" -ne 0 ]
      then
        exec sudo "$0"
      fi
    ''] ++ builtins.map (usercfg: ''
      mkdir -m 700 -p ${usercfg.dir.data}
      chown ${usercfg.username} ${usercfg.dir.data}
      mkdir -m 700 -p ${usercfg.dir.persist}
      chown ${usercfg.username} ${usercfg.dir.persist}
      ${pkgs.nix}/bin/nix build "''${1:-${./../..}}#homeConfigurations.${usercfg.username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation
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
  flex = (usercfg: pkgs.writeShellScriptBin "flex" ''
    ${overflex}
    ${pkgs.nix}/bin/nix build "''${1:-${flakedir}}#homeConfigurations.${usercfg.username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation
    ${usercfg.dir.persist}/generation/activate
  '');
  flex-rebuild = (usercfg: pkgs.writeShellScriptBin "flex-rebuild" ''
    ${overflex}
    sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakedir}}
    sudo ${rehome}/bin/rehome ''${1:-${flakedir}}
    ${usercfg.dir.persist}/generation/activate
  '');
in
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  # Required for impermanence
  programs.fuse.userAllowOther = true;

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

  # Create users
  users.mutableUsers = false;

  users.users = builtins.listToAttrs (builtins.map (usercfg:
    lib.nameValuePair usercfg.username {
      home = usercfg.dir.home;

      isNormalUser = true;
      password = usercfg.password;

      # Use zsh shell
      shell = pkgs.zsh;

      extraGroups = lib.mkIf usercfg.superuser [ "wheel" "networkmanager" ];

      packages = [
        (flex-rebuild usercfg)
        (flex         usercfg)
      ];
    }
  ) users);

  postinstall = builtins.map (usercfg: {
    generator = ''
      sudo -u ${usercfg.username} mkdir -p ${usercfg.dir.config "ssh"}/.ssh
      sudo -u ${usercfg.username} ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${usercfg.dir.config "ssh"}/.ssh/id_rsa -N ""
    '';
  }) ssh-users;

  nix.settings.trusted-users = builtins.map (usercfg: usercfg.username) (
    builtins.filter (usercfg: usercfg.superuser) users
  );

  # file with a list of users
  # environment.etc."users".text =
  #   builtins.concatStringsSep "\n" ((builtins.attrNames users) ++ [""]);

  # activate home manager on startup
  # copied from https://github.com/nix-community/home-manager/blob/master/nixos/default.nix
  systemd.services = builtins.listToAttrs (builtins.map (usercfg:
    lib.nameValuePair ("home-manager-${utils.escapeSystemdPath usercfg.username}") {
      description = "Home Manager environment for ${usercfg.username}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nix-daemon.socket" ];
      after = [ "nix-daemon.socket" ];
      before = [ "systemd-user-sessions.service" ];

      environment = {};

      unitConfig = { RequiresMountsFor = usercfg.dir.home; };

      stopIfChanged = false;

      serviceConfig = {
        User = usercfg.username;
        Type = "oneshot";
        RemainAfterExit = "yes";
        TimeoutStartSec = 90;
        SyslogIdentifier = "hm-activate-${usercfg.username}";

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
  ) users);

}
