{ config, pkgs, lib, ... }:

let
  flex = pkgs.writeShellScriptBin "flex" ''
    STORE=$(curl -L "https://nightly.link/Astavie/dotfiles/workflows/build/main/${config.networking.hostName}.zip" -s | ${pkgs.unzip}/bin/funzip)
    nix copy --from ssh://astavie@10.241.158.162 $STORE --no-check-sigs --substitute-on-destination
    ${config.asta.sudo} nix-env -p /nix/var/nix/profiles/system --set $STORE
    ${config.asta.sudo} /nix/var/nix/profiles/system/bin/switch-to-configuration switch
  '';
  reentry = pkgs.writeShellScriptBin "reentry" ''
    TERRESTRIAL="terrestrial.local"
    MACADDR="18:c0:4d:e0:b6:3e"
    HOUSTON="raspberrypi.local"

    # try pinging terrestrial
    ping -c 1 -w 1 "$TERRESTRIAL"

    if [ $? -ne 0 ]; then
            echo "PC IS OFF? WAKEY WAKEY!"
            # no connection, we wake it up
            ${lib.getExe' pkgs.sshpass "sshpass"} -ppi ssh "$HOUSTON" "~/.local/bin/wakeonlan $MACADDR"
            sleep 1m
            echo "OKAY PC, TIME TO GET UP"
    fi

    # time to ssh now
    exec ssh "$TERRESTRIAL" 
  '';
in
lib.module config "ssh" {
  home.packages = [ flex reentry ];
  asta.backup.directories = [ "ssh/.ssh" ];
} (users: {
  asta.postinstall.scripts = lib.mapAttrsToList (user: cfg: {
    inherit user;
    script = "${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${cfg.dir.config "ssh"}/.ssh/id_rsa -N ''";
    dirs = [ "${cfg.dir.config "ssh"}/.ssh" ];
  }) users;
})
