{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    xwaylandvideobridge
    ((discocss.override { discordAlias = true; }).overrideAttrs {
      src = fetchFromGitHub {
        owner = "bddvlpr";
        repo = "discocss";
        rev = "37f1520bc90822b35e60baa9036df7a05f43fab8";
        hash = "sha256-BFTxgUy2H/T92XikCsUMQ4arPbxf/7a7JPRewGqvqZQ=";
      };
    })
  ];

  backup.directories = [
    "discord/.config/discord"
  ];
}
