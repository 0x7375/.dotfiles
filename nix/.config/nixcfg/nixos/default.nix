{
  myLib,
  system,
  inputs,
  ...
}:

{
  disabledModules = [ "services/networking/syncthing.nix" ];

  imports = [
    ./cli
    ./gui
    ../lib
    inputs.agenix.nixosModules.default
  ] ++ (myLib.filesIn ./modules);

  environment.systemPackages = [ inputs.agenix.packages.${system}.default ];
}
