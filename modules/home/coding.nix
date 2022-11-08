{ pkgs, lib, ... }:

let
  parsers = [ "lua" "nix" "typescript" "haskell" ];
  ols = pkgs.stdenv.mkDerivation {
    pname = "ols";
    version = "20221027";

    src = pkgs.fetchFromGitHub {
      owner = "DanielGavin";
      repo = "ols";
      rev = "ab9c17b403527bc07d65d5c47ecb25bec423ddac";
      sha256 = "sha256-a6ii6r+zYfO8AJzrL4TWr6Qtze27CZV9MMrA+N8oX+M=";
    };

    buildInputs = [ pkgs.odin ];

    postPatch = ''
      patchShebangs build.sh
    '';

    buildPhase = ''
      ./build.sh
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp ols $out/bin
    '';
  };
in
{
  nixpkgs.overlays = [(final: prev: {
    # NOTE: We need the unstable version of tree-sitter because tree-sitter-nix in 22.05 is broken
    tree-sitter = final.unstable.tree-sitter;

    # Update odin
    odin = prev.odin.overrideAttrs (self: prev: rec {
      version = "dev-2022-10";
      src = pkgs.fetchFromGitHub {
        owner = "odin-lang";
        repo = "Odin";
        rev = version;
        sha256 = "sha256-D6dhsIU2Hm1XQ4G44C0ukJEgiO4tTmZ7CIezWi9CdOY=";
      };
      LLVM_CONFIG = "${pkgs.llvm.dev}/bin/llvm-config";
      postPatch = ''
        sed -i 's/^GIT_SHA=.*$/GIT_SHA=/' build_odin.sh
        patchShebangs build_odin.sh
      '';
    });
  })];

  home.packages = with pkgs; [
    # Haskell
    cabal2nix
    cabal-install
    ghc
    haskell-language-server

    # Odin
    odin
    ols

    # Neovim
    neovim
    ripgrep
    xclip
    fd

    # Node.js
    nodejs
    nodePackages.npm
    nodePackages.typescript-language-server
    
    # Other
    sumneko-lua-language-server
    rnix-lsp
  ];

  home.file = builtins.listToAttrs (builtins.map (parser:
    lib.nameValuePair ".config/nvim/parser/${parser}.so" {
      source = "${pkgs.tree-sitter.builtGrammars."tree-sitter-${parser}"}/parser";
    }
  ) parsers) // {
    ".config/nvim/init.lua".source = ../../config/nvim.lua;
    "odin/core".source = "${pkgs.odin}/bin/core";
  };
}
