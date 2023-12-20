{ pkgs, ... }:

{
  home.packages = with pkgs; [
    typst
    typst-lsp
    typstfmt
    typst-live
  ];
}
