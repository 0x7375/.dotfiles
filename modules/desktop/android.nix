{
  flake.modules.nixos.desktop =
    { config, ... }:
    {
      users.users.${config.me.user}.extraGroups = [ "adbusers" ];
    };

  flake.modules.generic.desktop =
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
