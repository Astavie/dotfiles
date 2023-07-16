{ ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
