{ flakeDir, ... }:

{
    programs.git.extraConfig.safe.directory = flakeDir;
}
