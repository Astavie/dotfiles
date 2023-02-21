{ ... }:

{
  programs.git = {
    enable = true;
    extraConfig = { pull.rebase = false; };
  };

  backup.directories = [
    "ssh/.ssh"
  ];
}
