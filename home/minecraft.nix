{ pkgs, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
    glfw-wayland-minecraft
  ];

  backup.directories = [
    "PrismLauncher/.local/share/PrismLauncher"
  ];
}
