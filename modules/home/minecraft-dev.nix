{ pkgs, lib, ... }:

let
  hotswap-agent-src = pkgs.fetchFromGitHub {
    owner = "HotswapProjects";
    repo = "HotswapAgent";
    rev = "99e9a89570504206f2e60b6105d57a12119864aa";
    sha256 = "sha256-FEGq8yM5N6Irp4dV2VqQ7kH/9342RWqgHPqS/x0CCBA=";
  };
  hotswap-agent-patches = [
    (pkgs.fetchpatch {
      # fix proxy crash
      url = "https://github.com/Astavie/HotswapAgent/commit/eeb0e95c863d5f975aebdd8146b46150df4d1902.patch";
      sha256 = "sha256-qVyngRJuxaOVgSrZzSNXAQF9VnRVDDFjif8nS/EUwaE=";
    })
  ];

  hotswap-agent-dependencies = with pkgs; stdenv.mkDerivation {
    name = "hotswap-agent-dependencies";
    buildInputs = [ jetbrains.jdk maven ];
    src = hotswap-agent-src;
    patches = hotswap-agent-patches;

    buildPhase = ''
      while mvn package -DskipTests -Dmaven.repo.local=$out/.m2 -Dmaven.wagon.rto=5000; [ $? = 1 ]; do
        echo "timeout, restart maven to continue downloading"
      done
    '';
    # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
    installPhase = ''
        find $out/.m2 -type f -regex '.+\\(\\.lastUpdated\\|resolver-status\\.properties\\|_remote\\.repositories\\)' -delete
    '';
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-5Sd90f8OLGF5frcGPSTnKpIOeasqaQueyTerOpRkf84=";
  };
  hotswap-agent = with pkgs; stdenv.mkDerivation {
    name = "hotswap-agent";
    version = "1.4.2-SNAPSHOT";
    buildInputs = [ jetbrains.jdk maven ];
    src = hotswap-agent-src;
    patches = hotswap-agent-patches;
  
    buildPhase = ''
      # 'maven.repo.local' must be writable so copy it out of nix store
      mvn package --offline -DskipTests -Dmaven.repo.local=${hotswap-agent-dependencies}/.m2
    '';

    installPhase = ''
      mkdir $out
      cp hotswap-agent/target/hotswap-agent.jar $out/
    '';
  };
in
{
  home.packages = with pkgs; [
    maven
    (writeShellScriptBin "gradlew-hotswap" ''
      ./gradlew $@ -Dastavie.jvm="-XX:+AllowEnhancedClassRedefinition -javaagent:${hotswap-agent}/hotswap-agent.jar=autoHotswap=true,disablePlugin=Log4j2 --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.desktop/java.beans=ALL-UNNAMED"
    '')
    (java-language-server.overrideAttrs (final: prev: {
      patches = (prev.patches or []) ++ [
        (fetchpatch {
          # remove deprecated rangeLength
          url = "https://github.com/Astavie/java-language-server/commit/342b435decbc739b0d23da1bbe2e0cd376c9f299.patch";
          sha256 = "sha256-aK7HXwMQN4k64q2rXo2hcdaYFhhOIIQuJGy4tyAFYuc=";
        })
        (fetchpatch {
          # clamp lineLength to 0 or above
          url = "https://github.com/Astavie/java-language-server/commit/73c71f27aa0b9aa894432e43d195e444b8a616fd.patch";
          sha256 = "sha256-brFvRn+TkYmXQ3VfufeGkDDbHIxK1TMSh0TjlN/026Y=";
        })
        (fetchpatch {
          # continue response
          url = "https://github.com/Astavie/java-language-server/commit/409d28de5fa724ddd1f7bfa82a09d88dc89976bc.patch";
          sha256 = "sha256-x+yWWPtuTa4sJYFFPxKKJZNhSArF2rlQVWvZ3ZubIAE=";
        })
        (fetchpatch {
          # make debugger quiet
          url = "https://github.com/Astavie/java-language-server/commit/430a066b7d4100184e7073f713415374116b68b6.patch";
          sha256 = "sha256-v5nRVIUNTwHQ7mjTCmV+lVAVs5MhM3qRDVcKqr4KRgU=";
        })
        (fetchpatch {
          # gradle dependency support
          url = "https://github.com/Astavie/java-language-server/commit/a876a3691fc88c2f7e75d63d7ae10bf299620df1.patch";
          sha256 = "sha256-t4FXxHuqFQ7sCHX46zCHZol23AsqYLmLGl+LmpPGGh4=";
        })
      ];

      postInstall = (prev.postInstall or "") + ''
        makeWrapper $out/share/java/java-language-server/debug_adapter_linux.sh $out/bin/java-debug-adapter
      '';
    }))
    jetbrains.jdk
  ];

  # java LSP
  programs.helix.languages = [{
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
