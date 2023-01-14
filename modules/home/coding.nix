{ pkgs, lib, ... }:

{
    # TODO: MOVE THE FOLLOWING PACKAGES TO LOCAL shell.nix FILES
  home.packages = with pkgs; [
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
    marksman
  ];

  home.file."odin/core".source = "${pkgs.odin}/bin/core";

  # Helix
  programs.helix.enable = true;
  programs.helix.package = pkgs.unstable.helix;
  programs.helix.settings.theme = "catppuccin_mocha";
}
