{ ... }:

{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
      };
    };
  };

  home.file.".mime.types".text = ''
    type=text/plain exts=md,mkd,mkdn,mdwn,mdown,markdown, desc="Markdown document"
  '';

  asta.backup.directories = [
    "firefox/.mozilla/firefox/default"
  ];
}
