{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    # cmd utils
    mc
    pulseaudio
    shell_gpt
    pre-commit

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

  backup.directories = [
    "autojump/.local/share/autojump"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
    "shell_gpt/.config/shell_gpt"
  ];

  # Helix
  programs.helix.enable = true;
  programs.helix.settings.editor = {
    line-number = "relative";
    completion-replace = true;
    lsp.display-messages = true;
    lsp.display-inlay-hints = true;
    # soft-wrap.enable = true;
  };
  home.sessionVariables.EDITOR = "${config.programs.helix.package}/bin/hx";

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';

  # LSP settings
  programs.helix.languages = {
    # JAVA
    language-server.java-language-server = {
      command = "java-language-server";
    };
    language-server.deno-lsp = {
      command = "deno";
      args = ["lsp" "--unstable"];
      config = { enable = true; lint = true; unstable = true; };
    };

    language = [{
      name = "java";
      scope = "source.java";
      injection-regex = "java";
      file-types = ["java"];
      roots = ["pom.xml"];
      language-servers = [ "java-language-server" ];
      indent = { tab-width = 4; unit = "    "; };
      debugger = {
        name = "java-debug-adapter";
        transport = "stdio";
        command = "java-debug-adapter";
        args = [ "--quiet" ];
        templates = [
          {
            name = "attach to jvm";
            request = "attach";
            completion = [{ name = "port"; default = "5005"; }];
            args = { port = "{0}"; sourceRoots = [ "src/main/java" "src/client/java" ]; };
          }
        ];
      };
    } {
      name = "typescript";
      language-id = "typescript";
      scope = "source.ts";
      injection-regex = "^(ts|typescript)$";
      file-types = ["ts"];
      shebangs = ["deno" "node"];
      roots = ["deno.json" "deno.jsonc" "package.json" "tsconfig.json"];
      comment-token = "//";
      indent = { tab-width = 2; unit = "  "; };
      grammar = "typescript";
      language-servers = ["deno-lsp"];
    }];
  };

  # midnight commander
  home.file.".config/mc/ini".text = ''
    [Midnight-Commander]
    skin=theme
    use_internal_edit=false
  '';

}
