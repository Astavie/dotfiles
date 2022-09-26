{
  # custom inputs
  users, hostname,

  # system inputs
  pkgs, utils, lib, ...
}@inputs:

let
  sudo = "doas";

  # list of users with ssh-keygen flag
  ssh-users = lib.filterAttrs (_: usercfg: usercfg.specialArgs.ssh-keygen or false) users;

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
      ${pkgs.nix}/bin/nix build "''${1:-${./../..}}#homeConfigurations.${username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation
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
    ${pkgs.nix}/bin/nix build "''${1:-${./../..}}#homeConfigurations.${username}@${hostname}.activationPackage" --out-link ${usercfg.dir.persist}/generation
    ${usercfg.dir.persist}/generation/activate
  '');
  flex-rebuild = (username: usercfg: pkgs.writeShellScriptBin "flex-rebuild" ''
    ${overflex}
    ${sudo} ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${./../..}}
    ${sudo} ${rehome}/bin/rehome ''${1:-${./../..}}
    ${usercfg.dir.persist}/generation/activate
  '');
in
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  # Use doas, not sudo
  security.sudo.enable = false;
  security.doas.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true; # use xkbOptions in tty.
  };

  # Sound service
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Some handy base packages
  environment.systemPackages = with pkgs; [
    git neofetch rehome
  ];

  # Timezone
  time.timeZone = "Europe/Amsterdam";

  # Create users
  users.mutableUsers = false;

  users.users = builtins.mapAttrs (username: usercfg: {
    home = usercfg.dir.home;

    isNormalUser = true;
    password = ""; # TODO

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups = lib.mkIf usercfg.superuser [ "wheel" "networkmanager" ];

    packages = [
      (flex-rebuild username usercfg)
      (flex         username usercfg)
    ];
  }) users;

  postinstall.sudo = sudo;
  postinstall.scripts = lib.mapAttrsToList (username: usercfg: {
    script = "${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${usercfg.dir.config "ssh"}/.ssh/id_rsa -N ''";
    user = username;
    dirs = [ "${usercfg.dir.config "ssh"}/.ssh" ];
  }) ssh-users;

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
