{
  config,
  inputs,
  mkNixos,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.me) secrets wm;
in
lib.mkIf (wm.enable && secrets.enable) (mkNixos {
  nixpkgs.overlays = [
    (final: prev: {
      token2-cli = final.callPackage ./_token2-cli.nix {
        src = inputs.token2;
      };
    })
  ];

  packages = [ pkgs.token2-cli ];

  me.wm.bindings."Mod+u" = pkgs.writeShellScript "totp-menu" ''
    tokens=$(sudo ${lib.getExe pkgs.token2-cli} get_all 2>&1 | grep -iv "touch")
    selected=$(echo "$tokens" | awk -F'] | - ' '{print $2}' | bemenu -i -l 10 -p "TOTP")
    echo "$tokens" | grep -F "$selected" | head -n 1 | awk '{print $NF}' | tr -d '\r\n' | ${config.me.wm.copy}
  '';

  nixpkgs.config.permittedInsecurePackages = [
    "python3.12-ecdsa-0.19.1"
  ];
})
