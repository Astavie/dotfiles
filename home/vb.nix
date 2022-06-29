{ pkgs, config, lib, ... }:

{
    programs.git.extraConfig.safe.directory = "/media/sf_dotfiles";
}
