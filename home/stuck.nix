# hahahaha home/stuck get it ?? HOMESTUCK
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    unofficial-homestuck-collection
  ];
  asta.backup.directories = [
    "homestuck/.config/unofficial-homestuck-collection"
    "homestuck/.config/unofficial-homestuck-collection-assets"
  ];
}
