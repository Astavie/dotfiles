{ pkgs, ... }:

let
  davis = pkgs.rustPlatform.buildRustPackage rec {
    pname = "davis";
    version = "0.1.3";

    src = pkgs.fetchFromGitHub {
      owner = "SimonPersson";
      repo = "davis";
      rev = version;
      hash = "sha256-Xw4X9n0PCuigZhBA6so8pVI26pLRGeGjtR0l7uHw1vA=";
    };

    cargoHash = "sha256-gpxcJbl2FrWjsPUi/BBZ/uyoVxmbBlXT7KYbESpI1+I=";
  };
in
{
  # There's an MPD music server hosted on my server
  # This is for connecting to that server

  # commandline mpd client
  home.packages = [ davis pkgs.skim ];

  home.file.".config/davis/davis.conf".text = ''
    [tags]
    # The list of enabled tags
    enabled=Composer,Work,Conductor,Ensemble,Performer,Label,Opus,RecordingDate,Rating,Genre,Location
    # Change the label of "RecordingDate" to "Recording Date"
    RecordingDate=Recording Date
    [hosts]
    # Connect to server for music
    default=10.241.158.162
  '';

  home.file.".config/davis/bin/davis-fzf" = {
    source = ./davis-fzf.sh;
    executable = true;
  };

  # snapcast client service for streaming the music
  systemd.user.services.snapclient-local = {
    Install = {
      WantedBy = [
        "pipewire.service"
      ];
    };
    Unit = {
      After = [
        "pipewire.service"
      ];
    };
    Service = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h 10.241.158.162";
    };
  };
}
