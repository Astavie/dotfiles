{ ... }:

{
  mkUser = input: {
    inherit (input) username password modules;
    superuser = input.superuser or false;

    dir = {
      home = input.dir.home or "/home/${input.username}";
      data = input.dir.data or "/data/${input.username}";
      persist = input.dir.persist or "/persist/${input.username}";
    };

    specialArgs = input.specialArgs or {};
  };

  mkSystem = input: {
    inherit (input) hostname hostid users system modules;
    flakedir = input.flakedir or ./..;

    specialArgs = input.specialArgs or {};
    sharedModules = input.sharedModules or [];
  };
}
