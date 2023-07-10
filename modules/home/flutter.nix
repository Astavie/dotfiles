{ pkgs, ... }:

let 
  android-sdk = pkgs.androidSdk (sdk: with sdk; [
    build-tools-29-0-2
    tools
    emulator
    patcher-v4
    cmdline-tools-latest
    platforms-android-31
    platform-tools
  ]);
in 
{
  home.packages = with pkgs; [
    jdk8
    dart
    flutter
    android-file-transfer
    android-sdk
  ];
  home.sessionVariables.ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
  home.sessionVariables.ANDROID_HOME     = "${android-sdk}/share/android-sdk";
}
