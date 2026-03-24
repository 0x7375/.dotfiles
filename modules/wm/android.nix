{
  flake.nixos.wm =
    { config, ... }:
    {
      users.users.${config.me.user}.extraGroups = [ "adbusers" ];
    };

  flake.shared.wm =
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
