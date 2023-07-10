{ ... }:

{
  services.easyeffects = {
    enable = true;
    preset = "Noise\\ Reduction";
  };
  backup.directories = [
    "pipewire/.local/state/wireplumber"
    "easyeffects/.config/easyeffects"
  ];
}
