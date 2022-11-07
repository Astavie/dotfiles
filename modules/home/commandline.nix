{ inputs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    # Make history lookup match everything before cursor
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[OA" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
      bindkey "^[OB" history-beginning-search-forward
      bindkey "^[[3~" delete-char

      display-prompt() {
        NAKED="%d%n@%m"
        N=$(($COLUMNS - ''${#$(print -P "''${NAKED}")} ))
        SPACE=$(printf "%''${N}s")

        print -P "\n%K{blue}%F{black}%d''${SPACE}%n@%m%k%f"
        emulate -L zsh; ls -A;
      }

      PS1="> "
      PS2="  "

      export GTK_THEME="${import ../../config/gtk/theme.nix}"

      add-zsh-hook chpwd display-prompt

      display-prompt
    '';

    envExtra = ''
      EDITOR=nvim
    '';

    plugins = [{
      name = "auto-notify";
      src = inputs.zsh-auto-notify;
    }];
  };

  programs.autojump.enable = true;

  backup.files       = [ "zsh/.zsh_history" ];
  backup.directories = [ "autojump/.local/share/autojump" ];
}
