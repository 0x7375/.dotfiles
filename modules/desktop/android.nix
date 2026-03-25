{
  flake.nixos.desktop =
    { config, ... }:
    {
      users.users.${config.me.user}.extraGroups = [ "adbusers" ];
    };

  flake.shared.desktop =
    {
      pkgs,
      ...
    }:
    {
      unfree-packages = [ "android-studio-stable" ];

      packages = with pkgs; [
        android-tools
        # android-studio
        scrcpy
      ];
    };
}
