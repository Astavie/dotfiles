{ pkgs, lib, ... }:

let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? pkgs.stdenv, fetchurl ? pkgs.fetchurl, pname, version, addonId, url, sha256, meta, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );
in
{
  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
      };
    };
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      lastpass-password-manager
      i-dont-care-about-cookies
      (buildFirefoxXpiAddon {
        pname = "catppuccin-mocha-lavender";
        version = "old";
        addonId = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";
        url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_lavender.xpi";
        sha256 = "70292b0b8652cbab408d15d261dc5150f690fb5bbaf96f4e7317256c7d9b7933";
        meta = {};
      })
    ];
  };

  backup.directories = [
    "firefox/.mozilla/firefox/default"
  ];
}
