{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ((unstable.discocss.override {
      inherit discord;
      discordAlias = true;
    }).overrideAttrs (self: prev: {
      postPatch = ''
        sed -i '/^command -v/d' discocss
        echo 'exec $DISCOCSS_DISCORD_BIN' >> discocss
      '';
    }))
    (stdenv.mkDerivation rec {
      pname = "discord-screenaudio";
      version = "1.4.0";

      src = fetchFromGitHub {
        owner = "maltejur";
        repo = "discord-screenaudio";
        rev = "v${version}";
        sha256 = "sha256-TOPDrJEgwny6RtVvdR+ysRR5iAtMMzkfAmw1UN3VVf0=";
        fetchSubmodules = true;
      };

      depsBuildBuild = [ buildPackages.stdenv.cc ];
      nativeBuildInputs = [ qt5.wrapQtAppsHook cmake pkg-config ];
      buildInputs = with qt5; with libsForQt5; [ pipewire qtbase qtwebengine knotifications kglobalaccel kxmlgui ];

      cmakeFlags = [
        "-DPipeWire_INCLUDE_DIRS=${pipewire.dev}/include/pipewire-0.3"
        "-DSpa_INCLUDE_DIRS=${pipewire.dev}/include/spa-0.2"
      ];
    })
  ];

  home.file.".config/discocss/custom.css".source = ../../config/discord.css;

  backup.directories = [
    "discord/.config/discord"
    "discord-screenaudio/.local/share/discord-screenaudio"
  ];
}
