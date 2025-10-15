{
  myLib,
  ...
}:

{
  imports = [
    ./options.nix
  ]
  ++ (myLib.filesIn ./home)
  ++ (myLib.filesIn ../../home);

  programs.alacritty.settings.env.WINIT_X11_SCALE_FACTOR = "1.11";
}
