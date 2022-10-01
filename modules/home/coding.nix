{ pkgs, lib, themePath, ... }:

let
  parsers = [ "lua" "nix" "typescript" "haskell" ];
in
{
  # discover installed fonts
  fonts.fontconfig.enable = true;

  nixpkgs.overlays = [(final: prev: {
    # NOTE: We need the unstable version of tree-sitter because tree-sitter-nix in 22.05 is broken
    tree-sitter = final.unstable.tree-sitter;
  })];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    kitty

    sumneko-lua-language-server
    rnix-lsp
    nodePackages.typescript-language-server

    ghc
    haskell-language-server

    neovim

    nodejs
    nodePackages.npm
  ];

  home.file = builtins.listToAttrs (builtins.map (parser:
    lib.nameValuePair ".config/nvim/parser/${parser}.so" {
      source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${parser}"}/parser";
    }
  ) parsers) // {
    ".config/nvim/init.lua".source = ../../config/nvim.lua;
    ".config/kitty/kitty.conf".source = "${themePath}/kitty.conf";
  };
}
