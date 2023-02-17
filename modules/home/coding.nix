{ pkgs, lib, ... }:

{
    # TODO: MOVE THE FOLLOWING PACKAGES TO LOCAL shell.nix FILES
  home.packages = with pkgs; [
    # Haskell
    # cabal2nix
    # cabal-install
    # haskell.compiler.ghc942
    # haskell.packages.ghc942.haskell-language-server
    # stack

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

  # backup openxr runtimes
  backup.directories = [
    "openxr/.config/openxr"
  ];

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';

  # save odin core files for ols to use
  home.file."odin/core".source = "${pkgs.odin}/bin/core";

  # Helix
  programs.helix.enable = true;
  programs.helix.package = pkgs.unstable.helix;
  programs.helix.settings.theme = "catppuccin_mocha";
}
