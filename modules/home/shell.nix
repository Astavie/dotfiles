{ inputs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      echo -ne '\e[?1004h'
      bind \e\[I 'kitty @set-colors ${../../config/kitty.conf}'
      bind \e\[O 'kitty @set-colors ${../../config/kitty_unfocused.conf}'
    '';
    functions = {
      fish_prompt = ''
        if test "$PWD" != "$PWD_PREV"
          echo

          set_color -b red
          set_color black
          echo $PWD
          set_color normal
          
          ls -AC -w $COLUMNS --group-directories-first -F --color
        end
        
        echo '> '
        set -g PWD_PREV $PWD
      '';
    };
  };
      
  home.sessionVariables.EDITOR = "hx";
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.autojump.enable = true;

  backup.directories = [
    "autojump/.local/share/autojump"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
  ];
}
