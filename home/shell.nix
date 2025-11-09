{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # cmd utils
    mc
    pulseaudio
    shell-gpt
    pre-commit
    unstable.devenv

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
  programs.autojump.enable = true;

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

  # midnight commander
  home.file.".config/mc/ini".text = ''
    [Midnight-Commander]
    skin=theme
    use_internal_edit=false
  '';

  # backup
  asta.backup.directories = [
    "autojump/.local/share/autojump"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
    "shell_gpt/.config/shell_gpt"
  ];
}
