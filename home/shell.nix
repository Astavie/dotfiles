{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    mc
    pulseaudio
    nil
    shell_gpt
  ];

  programs.fish = {
    enable = true;
    functions = {
      s = ''
        ssh $argv
      '';
      spaceflight = ''
        set -l ip (awk '/^  HostName / { print $2 }' ~/.ssh/config)
        echo $ip

        # setup audio
        ssh terrestrial "pactl load-module module-native-protocol-tcp port=4656 auth-anonymous=1"
        set -x source (pactl load-module module-tunnel-source server=tcp:$ip:4656 source=alsa_output.pci-0000_00_1f.3.analog-stereo.monitor)
        echo $source

        pw-link tunnel-source.tcp:$ip:4656:capture_FL alsa_output.pci-0000_00_1f.3.analog-stereo:playback_FL
        pw-link tunnel-source.tcp:$ip:4656:capture_FR alsa_output.pci-0000_00_1f.3.analog-stereo:playback_FR

        function unload --on-signal SIGINT
          pactl unload-module $source
        end

        # setup video
        ssh -t -L 5900:localhost:5900 terrestrial "x11vnc -xauth ~/.local/share/sx/xauthority -localhost -display :1"

        # unload
        unload
      '';
      fish_prompt = ''
        if test "$PWD" != "$PWD_PREV"
          echo

          set -l left    "$PWD"
          set -l right   (whoami)@(prompt_hostname)
          set -l padding (math $COLUMNS - (string length -- "$left$right"))

          set_color -b blue
          set_color black
          echo (printf "%s%-"$padding"s%s" "$left" " " "$right")
          set_color normal

          ls -AC -w $COLUMNS --group-directories-first -F --color
        end
        
        echo '> '
        set -g PWD_PREV $PWD
      '';
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.autojump.enable = true;

  backup.directories = [
    "autojump/.local/share/autojump"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
    "shell_gpt/.config/shell_gpt"
  ];

  # Helix
  programs.helix.enable = true;
  programs.helix.settings.theme = "catppuccin_mocha";
  home.sessionVariables.EDITOR = "${config.programs.helix.package}/bin/hx";

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';

  # LSP settings
  programs.helix.languages.language = [{
    name = "java";
    scope = "source.java";
    injection-regex = "java";
    file-types = ["java"];
    roots = ["pom.xml"];
    language-server = { command = "java-language-server"; };
    indent = { tab-width = 4; unit = "    "; };
    debugger = {
      name = "java-debug-adapter";
      transport = "stdio";
      command = "java-debug-adapter";
      args = [ "--quiet" ];
      templates = [
        {
          name = "attach to jvm";
          request = "attach";
          completion = [{ name = "port"; default = "5005"; }];
          args = { port = "{0}"; sourceRoots = [ "src/main/java" "src/client/java" ]; };
        }
      ];
    };
  }];

  # midnight commander
  home.file.".config/mc/ini".text = ''
    [Midnight-Commander]
    skin=theme
    use_internal_edit=false
  '';

}
