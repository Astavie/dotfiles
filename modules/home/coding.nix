{ pkgs, ... }:

{
  # nix language server
  home.packages = with pkgs; [ nil ];

  # make rust use sccache
  home.file.".cargo/config.toml".text = ''
    [build]
    rustc-wrapper = "${pkgs.sccache}/bin/sccache"
  '';

  # LSP settings
  programs.helix.languages.language = [{
    name = "java";
    scope = "source.java";
    injection-regex = "java";
    file-types = ["java"];
    roots = ["pom.xml"];
    language-server = { command = "java-language-server"; };
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
  }];
}
