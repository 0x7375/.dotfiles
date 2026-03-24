{
  flake.nixos.isoImg =
    {
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

      isoImage.squashfsCompression = "gzip -Xcompression-level 1";

      systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = lib.mkForce "yes";
          KbdInteractiveAuthentication = lib.mkForce true;
        };
        extraConfig = lib.mkForce "";
      };

      nixpkgs.hostPlatform = "x86_64-linux";

      hardware.enableRedistributableFirmware = true;

      networking.wireless.enable = lib.mkForce false;
    };
}
