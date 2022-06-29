{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
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
