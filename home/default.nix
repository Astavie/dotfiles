{ pkgs, ... }:

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
        print -P "\n%K{white}%F{black}%n %~%E%k%f"
        emulate -L zsh; ls;
      }

      add-zsh-hook chpwd display-prompt

      PS1="> "
      PS2="  "
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "astavie@pm.me";
    userName = "Astavie";
  };

  # Add github to known ssh hosts
  home.file.".ssh/known_hosts".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  # discover installed fonts
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
}
