{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # cmd utils
    pulseaudio
    pre-commit
    devenv

    # languages
    nil
  ];

  programs.fish = {
    enable = true;
    functions = {
      s = ''
        ssh -q $argv
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

        set -U GLOBAL_PWD $PWD
      '';
      fish_greeting = ''
        ${pkgs.krabby}/bin/krabby random
      '';
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # rust cmd utils
  programs.yazi.enable = true;
  programs.yazi.enableFishIntegration = true;
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

  # Helix
  programs.helix.enable = true;
  programs.helix.settings.editor = {
    line-number = "relative";
    completion-replace = true;
    lsp.display-messages = true;
    lsp.display-inlay-hints = true;
    # soft-wrap.enable = true;
  };
  programs.helix.languages = {
    language-server.rust-analyzer.config = {
      check.command = "clippy";
    };
  };
  home.sessionVariables.EDITOR = "${config.programs.helix.package}/bin/hx";

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';

  # backup
  asta.backup.directories = [
    "zoxide/.local/share/zoxide"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
  ];
}
