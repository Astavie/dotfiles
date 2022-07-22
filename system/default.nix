{
  # custom inputs
  users, flakeDir,

  # system inputs
  pkgs, utils, lib, ...
}:

let
  flakeDir' = if flakeDir == null then "git+https://github.com/Astavie/dotfiles" else flakeDir;
  flex = pkgs.writeShellScriptBin "flex" ''
    if [ "$EUID" -eq 0 ]
    then
      exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakeDir'}}
    else
      exec ${pkgs.home-manager}/bin/home-manager switch --flake ''${1:-${flakeDir'}}
    fi
  '';
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
    home = if usercfg ? home then usercfg.home else "/home/${username}";

    isNormalUser = true;
    password = usercfg.password;

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups = lib.mkIf (usercfg ? superuser && usercfg.superuser) [ "wheel" "networkmanager" ];
  }) users;

  systemd.services = lib.mapAttrs' (username: usercfg:
    lib.nameValuePair "home-manager-${utils.escapeSystemdPath username}" {
      # Copied from https://github.com/nix-community/home-manager/blob/master/nixos/default.nix
      description = "Home Manager environment for ${username}";
      wantedBy = [ "multi-user.target" ];
      wants = [ "nix-daemon.socket" ];
      after = [ "nix-daemon.socket" ];
      before = [ "systemd-user-sessions.service" ];

      environment = {};

      unitConfig = { RequiresMountsFor = if usercfg ? home then usercfg.home else "/home/${username}"; };

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
            # The activation script is run by a login shell to make sure
            # that the user is given a sane environment.
            # If the user is logged in, import variables from their current
            # session environment.
            eval "$(
              ${systemctl} --user show-environment 2> /dev/null \
              | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
            )"
            exec "$1"
          '';
        in "${setupEnv} ${flex}/bin/flex";
      };
    }
  ) users;

  nix.settings.trusted-users =
    lib.attrNames (
      lib.filterAttrs
        (_: usercfg: usercfg ? superuser && usercfg.superuser)
        users
    );
}
