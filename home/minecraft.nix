{ pkgs, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
    glfw-wayland-minecraft
  ];

  backup.directories = [{
    directory = "PrismLauncher/.local/share/PrismLauncher";
    # OH MY GOD THIS ISSUE
    # so, i kept crashing due to "too many open files"
    # this confused me, as my file descriptor limit seems to be 99999
    # HOWEVER!!
    # the default impermanence linking method is bindfs
    # and it appears that when accessing an fd within this bound fs,
    # the 'bindfs' process also in turn accesses the corresponding fd at the real location
    # this is all quite logical
    # HOWEVER!!
    # that 'bindfs' process has its own file descriptor limit: 1024!
    # and with enough mods and worldgen, this limit is easily breached...
    # the solution: using the symlink method
    method = "symlink";
  }];
}
