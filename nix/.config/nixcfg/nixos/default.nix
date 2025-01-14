{
  pkgs,
  myLib,
  inputs,
  ...
}:

{
  disabledModules = [ "services/networking/syncthing.nix" ];

  imports = [
    ./cli
    ./gui
    ../lib
    inputs.sops-nix.nixosModules.sops
  ] ++ (myLib.filesIn ./modules);

  environment.systemPackages = with pkgs; [ sops ];
}
