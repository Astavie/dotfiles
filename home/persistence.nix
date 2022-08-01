{
  # custom inputs
  username, datadir,

  # system inputs
  pkgs, ...
}:

{
  home.persistence."${datadir}" = {
    files = [
      ".zsh_history"
    ];
  };
}
