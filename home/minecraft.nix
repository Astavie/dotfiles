{ pkgs, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
  ];

  backup.directories = [
    "PrismLauncher/.local/share/PrismLauncher"
  ];
}
