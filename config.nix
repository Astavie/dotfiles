let
  users.astavie = {
    superuser = true;
    packages = pkgs: with pkgs; [
      torrential
      neofetch
      helvum
      gimp
      pavucontrol
      htop
      teams

      jdk8
      flutter
      android-file-transfer
    ];

    specialArgs.ssh-keygen = true;

    modules = [
      ./modules/home/coding.nix
      ./modules/home/commandline.nix
      ./modules/home/desktop.nix
      ./modules/home/discord.nix
      ./modules/home/firefox.nix
      ./modules/home/git.nix
      ./modules/home/steam.nix
      ({ inputs, pkgs, ... }: let 
        android-sdk = inputs.android-nixpkgs.sdk.${pkgs.system} (sdk: with sdk; [
          build-tools-29-0-2
          tools
          emulator
          patcher-v4
          cmdline-tools-latest
          platforms-android-31
          platform-tools
        ]);
      in {
        programs.git = {
          userEmail = "astavie@pm.me";
          userName = "Astavie";
        };
        home.packages = [ android-sdk ];
        home.sessionVariables.ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
        home.sessionVariables.ANDROID_HOME     = "${android-sdk}/share/android-sdk";
      })
    ];
  };
in
{
  systems = {
    terrestrial = {
      hostid = "93ad32f0";
      system = "x86_64-linux";
      stateVersion = "22.11";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/nvidia.nix
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/pipewire.nix
        ./modules/system/ssh.nix
        ./modules/system/steam.nix
        ./modules/system/xserver.nix
        ./modules/system/vbhost.nix
      ];
    };
    vb = {
      hostid = "85dd8e44";
      system = "x86_64-linux";
      stateVersion = "22.11";

      users = with users; { inherit astavie; };
      impermanence.enable = true;

      modules = [
        ./modules/system/hardware/uefi.nix
        ./modules/system/hardware/vb.nix
        ./modules/system/hardware/zfs.nix
        ./modules/system/base.nix
        ./modules/system/pipewire.nix
        ./modules/system/xserver.nix
      ];
    };
  };
}
