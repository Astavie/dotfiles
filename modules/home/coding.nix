{ pkgs, ... }:

{
  # discover installed fonts
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    kitty
  ];
}
