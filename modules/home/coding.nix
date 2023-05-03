{ pkgs, lib, ... }:

{
  # TODO: MOVE THE FOLLOWING PACKAGES TO LOCAL shell.nix FILES
  home.packages = with pkgs; [
    # C/C++
    clang
    clang-tools

    # Node.js
    nodejs
    nodePackages.npm
    nodePackages.typescript-language-server

    # Rust
    fenix.default.toolchain
    rust-analyzer
    bacon

    # Other languages
    sumneko-lua-language-server
    rnix-lsp
  ];

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';
}
