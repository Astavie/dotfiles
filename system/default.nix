{
  # custom inputs
  self, stateVersion, username, flakeDir,
  
  # system inputs
  pkgs, utils, lib, ...
}:

let
  flakeDir' = if flakeDir == null then ./.. else flakeDir; 
  flex = pkgs.writeShellScriptBin "flex" ''
    if [ "$EUID" -eq 0 ]
    then
      exec ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ''${1:-${flakeDir'}}
    else
      exec ${pkgs.home-manager}/bin/home-manager switch --flake ''${1:-${flakeDir'}}
    fi
  '';
  home = "/home/${username}";
in
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
  system.configurationRevision = if self ? rev then self.rev else null;
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
    inherit home;

    isNormalUser = true;
    password = "";

    packages = [ flex ];

    # Use zsh shell
    shell = pkgs.zsh;

    extraGroups  = [ "wheel" "networkmanager" ];
  };

  systemd.services."home-manager-${utils.escapeSystemdPath username}" = {
    # Copied from https://github.com/nix-community/home-manager/blob/master/nixos/default.nix
    description = "Home Manager environment for ${username}";
    wantedBy = [ "multi-user.target" ];
    wants = [ "nix-daemon.socket" ];
    after = [ "nix-daemon.socket" ];
    before = [ "systemd-user-sessions.service" ];

    environment = {};

    unitConfig = { RequiresMountsFor = home; };

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
  };

  nix.settings.trusted-users = [ username ];
}
