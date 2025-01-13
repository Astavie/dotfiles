{ pkgs, inputs, ... }:

let
  zen = inputs.zen-browser.packages."${pkgs.system}".default;
in
{
  home.packages = [zen];
  asta.backup.directories = [
    "zen/.zen"
  ];
  home.file.".mime.types".text = ''
    type=text/plain exts=md,mkd,mkdn,mdwn,mdown,markdown, desc="Markdown document"
  '';

}
