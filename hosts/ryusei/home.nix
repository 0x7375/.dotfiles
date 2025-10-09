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
}
