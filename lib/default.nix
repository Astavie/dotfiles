{ ... }:

{
  mkUser = usercfg: systemcfg: {
    inherit (usercfg) username password modules;
    superuser = usercfg.superuser or false;
    ssh-keygen = usercfg.ssh-keygen or false;

    dir = rec {
      # Base directories
      home = usercfg.dir.home or "/home/${usercfg.username}";
      data = usercfg.dir.data or "/data/${usercfg.username}";
      persist = if systemcfg.persist then (usercfg.dir.persist or "/persist/${usercfg.username}") else home;

      # Subdirectories
      config = if home == persist then (_: home) else (dir: "${persist}/${dir}");
    };

    specialArgs = usercfg.specialArgs or {};
  };

  mkSystem = systemcfg: {
    inherit (systemcfg) hostname hostid system modules;
    flakedir = systemcfg.flakedir or ./..;
    persist = systemcfg.persist or false;

    users = builtins.map (user: user systemcfg) systemcfg.users;

    specialArgs = systemcfg.specialArgs or {};
    sharedModules = systemcfg.sharedModules or [];
  };
}
