{ pkgs, ... }:

{
  # Flatpak (because the default service forces us to use xdg desktop portals, even on X11)
  # Based off https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/services/desktops/flatpak.nix
  environment.systemPackages = [ pkgs.flatpak ];
  security.polkit.enable = true;
  services.dbus.packages = [ pkgs.flatpak ];
  systemd.packages = [ pkgs.flatpak ];

  environment.profiles = [
    "$HOME/.local/share/flatpak/exports"
    "/var/lib/flatpak/exports"
  ];

  users.users.flatpak = {
    description = "Flatpak system helper";
    group = "flatpak";
    isSystemUser = true;
  };

  users.groups.flatpak = { };
}