{ pkgs, lib, ... }:

let
  parsers = [ "lua" "nix" "typescript" "haskell" "dart" "c_sharp" "rust" ];
in
{
  home.packages = with pkgs; [
    # Neovim
    neovim
    ripgrep
    xclip
    fd
    unixtools.xxd

    ## TODO: MOVE THE FOLLOWING PACKAGES TO LOCAL shell.nix FILES
    # Haskell
    cabal2nix
    cabal-install
    haskell.compiler.ghc942
    haskell.packages.ghc942.haskell-language-server
    stack

    # Odin
    odin
    ols

    # C/C++
    clang
    clang-tools

    # Node.js
    nodejs
    nodePackages.npm
    nodePackages.typescript-language-server

    # Rust
    unstable.cargo
    unstable.rustc
    unstable.bacon
    unstable.rust-analyzer

    # Other languages
    sumneko-lua-language-server
    rnix-lsp
    dart
  ];

  home.file = builtins.listToAttrs (builtins.map (parser:
    lib.nameValuePair ".config/nvim/parser/${parser}.so" {
      source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${builtins.replaceStrings ["_"] ["-"] parser}"}/parser";
    }
  ) parsers) // {
    ".config/nvim/init.lua".source = ../../config/nvim.lua;
    "odin/core".source = "${pkgs.odin}/bin/core";
  };

  # Helix
  programs.helix.enable = true;
  programs.helix.settings.theme = "catppuccin_mocha";
}
