{ ... }:

{
  # Add github to known ssh hosts
  home.file.".ssh/known_hosts".text = ''
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  programs.git = {
    enable = true;
    extraConfig = { pull.rebase = false; };
  };

  backup.files = [
    "ssh/.ssh/id_rsa"
    "ssh/.ssh/id_rsa.pub"
  ];
}
