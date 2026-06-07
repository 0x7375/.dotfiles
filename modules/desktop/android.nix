{
  flake.modules.nixos.desktop =
    {
      pkgs,
      config,
      ...
    }:
    {
      users.users.${config.me.user}.extraGroups = [ "adbusers" ];

      unfree-packages = [ "android-studio-stable" ];

      packages = with pkgs; [
        android-tools
        # android-studio
        scrcpy
      ];
    };
}
