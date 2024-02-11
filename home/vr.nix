{ pkgs, ... }:

{
  # openxr runtime
  home.file.".config/openxr/1/active_runtime.json".source = pkgs.wivrn-runtime;

  home.packages = with pkgs; [
    wivrn-server
    alvr
  ];
}
