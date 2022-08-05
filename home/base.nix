{
  # custom inputs
  username, dir,

  # system inputs
  pkgs, ...
}:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    # Make history lookup match everything before cursor
    initExtra = ''
      bindkey "$terminfo[kcuu1]" history-beginning-search-backward
      bindkey "$terminfo[kcud1]" history-beginning-search-forward

      display-prompt() {
        NAKED="%d%n@%m"
        N=$(($COLUMNS - ''${#$(print -P "''${NAKED}")} ))
        SPACE=$(printf "%''${N}s")

        print -P "\n%K{white}%F{black}%d''${SPACE}%n@%m%k%f"
        emulate -L zsh; ls -A;
      }

      PS1="> "
      PS2="  "

      add-zsh-hook chpwd display-prompt

      cd ${dir.data}
    '';

    envExtra = ''
      EDITOR=nvim
    '';
  };

  # Add github to known ssh hosts
  home.file.".ssh/known_hosts".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  programs.autojump.enable = true;
  programs.git = {
    enable = true;
    extraConfig = { pull.rebase = false; };
  };

  home.persistence."${dir.persist}" = {
    files = [
      ".zsh_history"
      ".local/share/autojump/autojump.txt"
    ];
  };
}
