{ config, ... }:

{
  modules = [({ pkgs, lib, utils, ... }:
    let
      flex = pkgs.writeShellScriptBin "flex" ''
        STORE=$(curl -L "https://nightly.link/Astavie/dotfiles/workflows/build/main/${config.hostname}.zip" -s | ${pkgs.unzip}/bin/funzip)
        nix copy --from ssh://astavie@10.241.158.162 $STORE --no-check-sigs --substitute-on-destination
        ${config.sudo} nix-env -p /nix/var/nix/profiles/system --set $STORE
        ${config.sudo} /nix/var/nix/profiles/system/bin/switch-to-configuration switch
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
        password = "admin"; # TODO

        # Use fish shell
        shell = pkgs.fish;

        extraGroups = [ "audio" "video" ] ++ lib.optionals usercfg.superuser [ "wheel" "networkmanager" "dialout" ];

        packages = [
          flex
        ];
      }) config.users;

      nix.settings.trusted-users = config.superusers;
    }
  )];
}
