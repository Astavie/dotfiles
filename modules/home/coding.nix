{ pkgs, ... }:

{
  # discover installed fonts
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    kitty
  ];

  home.file.".config/nvim" = {
    source = ../../config/nvim;
    recursive = true;
  };

  home.file.".config/kitty/kitty.conf".source = ../../config/kitty.conf;

  backup.directories = [
    "nvim/.config/nvim/plugin"
  ];
}
