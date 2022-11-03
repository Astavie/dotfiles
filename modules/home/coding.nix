{ pkgs, lib, ... }:

let
  parsers = [ "lua" "nix" "typescript" "haskell" ];
in
{
  nixpkgs.overlays = [(final: prev: {
    # NOTE: We need the unstable version of tree-sitter because tree-sitter-nix in 22.05 is broken
    tree-sitter = final.unstable.tree-sitter;
  })];

  home.packages = with pkgs; [
    sumneko-lua-language-server
    rnix-lsp
    nodePackages.typescript-language-server

    cabal2nix
    cabal-install
    ghc
    haskell-language-server

    neovim
    ripgrep
    xclip
    fd

    nodejs
    nodePackages.npm
  ];

  home.file = builtins.listToAttrs (builtins.map (parser:
    lib.nameValuePair ".config/nvim/parser/${parser}.so" {
      source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${parser}"}/parser";
    }
  ) parsers) // {
    ".config/nvim/init.lua".source = ../../config/nvim.lua;
  };
}
