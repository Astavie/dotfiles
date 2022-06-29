{ pkgs, config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
  };

  programs.git = {
    enable = true;
    userEmail = "astavie@pm.me";
    userName = "Astavie";
  };
}
