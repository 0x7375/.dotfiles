{ myLib, ... }:

{
  imports = [
    ./options.nix
  ]
  ++ (myLib.filesIn ./home)
  ++ (myLib.filesIn ../../home);

  wayland.windowManager.hyprland.settings.input = {
    accel_profile = "flat";
  };
}
