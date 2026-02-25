{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      push.autoSetupRemote = true;
      pull.rebase = false;
      init.defaultBranch = "main";
      safe.directory = "*";
    };
  };
}
