{ ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
