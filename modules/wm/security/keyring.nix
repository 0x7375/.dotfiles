{
  config,
  mkNixos,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  nixpkgs.overlays = [
    (final: prev: {
      pass-secret-service-rs = prev.callPackage ./_pass-secret-service-rs.nix { };
    })
  ];

  services.passSecretService = {
    enable = true;
    package = pkgs.pass-secret-service-rs;
  };

  packages = with pkgs; [
    pass
    gnupg
  ];

  userActivation =
    # bash
    ''
      if ! ${lib.getExe pkgs.gnupg} --list-secret-keys "secrets@localhost" &>/dev/null; then
        ${lib.getExe pkgs.gnupg} --batch --gen-key <<EOF
      %no-protection
      Key-Type: EdDSA
      Key-Curve: ed25519
      Subkey-Type: ECDH
      Subkey-Curve: cv25519
      Name-Real: Secrets
      Name-Email: secrets@localhost
      Expire-Date: 0
      %commit
      EOF
        ${lib.getExe pkgs.pass} init "secrets@localhost"
      fi
    '';
})
