{  ... }:

{
  backup.directories = [
    {
      directory = "steam/.steam";
      method = "symlink";
    }
    {
      directory = "steam/.local/share/Steam";
      method = "symlink";
    }

    # Game specific directories
    "factorio/.factorio"
  ];
}
