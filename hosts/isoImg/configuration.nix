{
  lib,
  config,
  myLib,
  inputs,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.home-manager.nixosModules.home-manager
    ./options.nix
  ] ++ (myLib.filesIn ../../nixos);

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkForce "yes";
      KbdInteractiveAuthentication = lib.mkForce true;
      AllowUsers = lib.mkForce null;
    };
    extraConfig = lib.mkForce "";
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  hardware.enableRedistributableFirmware = true;
  networking.hostName = config.me.hostname;

  networking.wireless.enable = false;
}
