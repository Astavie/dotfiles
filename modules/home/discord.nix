{ pkgs, ... }:

{
  home.packages = with pkgs; [
    discord discocss
    (pkgs.stdenv.mkDerivation {
      pname = "discord-screenaudio";
      version = "v1.3.1";

      src = pkgs.fetchFromGitHub {
        owner = "maltejur";
        repo = "discord-screenaudio";
        rev = "v1.3.1";
        sha256 = "sha256-gp+RrRlbFzCdPszb06R5pEuDie5r63a3HFxzI0zXpHA=";
        fetchSubmodules = true;
      };

      nativeBuildInputs = [ qt5.wrapQtAppsHook cmake pkg-config ];
      buildInputs = [ pipewire qt5.qtbase qt5.qtwebengine libsForQt5.knotifications ];

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
