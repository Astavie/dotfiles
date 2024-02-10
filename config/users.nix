{ config, ... }:

{
  modules = [({ pkgs, lib, utils, ... }:
    let
      flex = pkgs.writeShellScriptBin "flex" ''
        set -e
        if [ "$EUID" -ne 0 ]
        then
          exec ${config.sudo} "$0"
        fi
        STORE=$(curl -L "https://nightly.link/Astavie/dotfiles/workflows/build/main/${config.hostname}.zip" -s | funzip)
        nix copy --from ssh://user@10.241.250.179 $STORE --no-check-sigs
        nix-env -p /nix/var/nix/profiles/system --set $STORE
        /nix/var/nix/profiles/system/bin/switch-to-configuration switch
      '';
    in
    {
      # Create users
      # NOTE: we could add an option for the shell?
      programs.fish.enable = true;
      environment.systemPackages = [ pkgs.git ];
  
      users.mutableUsers = false;
      users.users = builtins.mapAttrs (username: usercfg: {
        home = usercfg.dir.home;

        isNormalUser = true;
        password = ""; # TODO

        # Use fish shell
        shell = pkgs.fish;

        extraGroups = [ "audio" "video" ] ++ lib.optionals usercfg.superuser [ "wheel" "networkmanager" ];

        packages = [
          flex
        ];
      }) config.users;

      nix.settings.trusted-users = config.superusers;
    }
  )];
}
