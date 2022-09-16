{ pkgs, lib, ... }:

let
  parsers = [ "lua" "nix" "typescript" ];
in
{
  # discover installed fonts
  fonts.fontconfig.enable = true;

  nixpkgs.overlays = [(final: prev: {
    tree-sitter = final.unstable.tree-sitter;
  })];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    kitty

    sumneko-lua-language-server
    rnix-lsp
    nodePackages.typescript-language-server

    neovim
  ];

  home.file = builtins.listToAttrs (builtins.map (parser:
    lib.nameValuePair ".config/nvim/parser/${parser}.so" {
      source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${parser}"}/parser";
    }
  ) parsers) // {
    ".config/nvim/init.lua".source = ../../config/nvim/init.lua;
    ".config/kitty/kitty.conf".source = ../../config/kitty.conf;
  };
}
