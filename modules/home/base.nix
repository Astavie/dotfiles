{
  # custom inputs
  username, dir,

  # system inputs
  pkgs, lib, config, ...
}:

let
  buildFirefoxXpiAddon = lib.makeOverridable ({ stdenv ? pkgs.stdenv, fetchurl ? pkgs.fetchurl, pname, version, addonId, url, sha256, meta, ... }:
    stdenv.mkDerivation {
      name = "${pname}-${version}";

      inherit meta;

      src = fetchurl { inherit url sha256; };

      preferLocalBuild = true;
      allowSubstitutes = true;

      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"
        install -v -m644 "$src" "$dst/${addonId}.xpi"
      '';
    }
  );
in
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "lastpass-password-manager"
  ];

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
      };
    };
    extensions = with config.nur.repos.rycee.firefox-addons; [
      ublock-origin
      lastpass-password-manager
      i-dont-care-about-cookies
      (buildFirefoxXpiAddon {
        pname = "catppuccin-mocha-lavender";
        version = "old";
        addonId = "{8446b178-c865-4f5c-8ccc-1d7887811ae3}";
        url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_lavender.xpi";
        sha256 = "70292b0b8652cbab408d15d261dc5150f690fb5bbaf96f4e7317256c7d9b7933";
        meta = {};
      })
    ];
  };

  home.packages = with pkgs; [
    helvum
  ];

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

      display-prompt
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

  backup.files = [
    "zsh/.zsh_history"
    "ssh/.ssh/id_rsa"
    "ssh/.ssh/id_rsa.pub"
  ];

  backup.directories = [
    "autojump/.local/share/autojump"
    "firefox/.mozilla/firefox/default"
  ];
}
