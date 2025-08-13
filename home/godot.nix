{ pkgs, ... }:

{
  home.packages = with pkgs; [
    godot-mono
    jetbrains.rider
    dotnet-sdk_8
  ];

  asta.backup.directories = [
    "jetbrains/.config/JetBrains"
    "jetbrains/.local/share/JetBrains"
    "godot/.config/godot"
    "godot/.local/share/godot"
  ];
}
