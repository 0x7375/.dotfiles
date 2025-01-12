{
  pkgs,
  config,
  myLib,
  ...
}:

{
  imports = [
    ../../nixos
    ./hardware.nix
    ./options.nix
  ] ++ (myLib.filesIn ./nixos);

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  networking.hostName = config.me.hostname;

  system.stateVersion = "24.11";
}
