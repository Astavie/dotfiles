{ config, pkgs, lib, ... }:

let
  flex = pkgs.writeShellScriptBin "flex" ''
    STORE=$(curl -L "https://nightly.link/Astavie/dotfiles/workflows/build/main/${config.networking.hostName}.zip" -s | ${pkgs.unzip}/bin/funzip)
    nix copy --from ssh://astavie@10.241.158.162 $STORE --no-check-sigs --substitute-on-destination
    ${config.asta.sudo} nix-env -p /nix/var/nix/profiles/system --set $STORE
    ${config.asta.sudo} /nix/var/nix/profiles/system/bin/switch-to-configuration switch
  '';
  subset = module: lib.mkOption {
    type = with lib.types; attrsOf (submodule module);
  };
  ssh-users = lib.filterAttrs (_: cfg: cfg.ssh.enable) config.asta.users;
in
{
  options.asta.users = subset (u: {
    options = {
      ssh.enable = lib.mkEnableOption "ssh";
    };
    config = lib.mkIf u.config.ssh.enable {
      modules = [{
        home.packages = [
          flex
        ];
      }];
    };
  });

  config.asta.postinstall.scripts = lib.mapAttrsToList (user: cfg: {
    inherit user;
    script = "${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${cfg.dir.config "ssh"}/.ssh/id_rsa -N ''";
    dirs = [ "${cfg.dir.config "ssh"}/.ssh" ];
  }) ssh-users;
}
