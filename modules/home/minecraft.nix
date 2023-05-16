{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    prismlauncher
    (openjdk8.overrideAttrs (final: prev: rec {
      version = "8u312-ga";
      src = fetchFromGitHub {
        owner = "openjdk";
        repo = "jdk8u";
        rev = "jdk${version}";
        sha256 = "sha256-y8bcg3+BJjs3xnfFXDw2D7fvgUNAgyQnuC1FxzbfF20=";
      };
    }))
  ];

  backup.directories = [
    "PrismLauncher/.local/share/PrismLauncher"
  ];
}
