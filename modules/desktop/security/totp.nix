{ self, ... }:

{
  flake.modules.nixos.desktop =
    {
      config,
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          token2-cli = final.callPackage ./_token2-cli.nix {
            src = inputs.token2;
          };
        })
      ];

      packages = [ pkgs.token2-cli ];

      me.desktop.bindings."Mod+u" = pkgs.writeShellScript "totp-menu" ''
        tokens=$(${lib.getExe pkgs.token2-cli} get_all 2>&1 | grep -iv "touch")
        selected=$(echo "$tokens" | awk -F'] | - ' '{print $2}' | ${lib.getExe pkgs.my.noctalia} dmenu -p "Copy OTP..." -g password)

        [ -z "$selected" ] && exit 0

        app="''${selected%% / *}"
        account="''${selected#* / }"

        ${lib.getExe pkgs.my.notify} "Security key" "Touch required" -i "fingerprint" -t 0
        ${lib.getExe pkgs.token2-cli} read_entry --app-name "$app" --account-name "$account" 2>&1 | tail -n 1 | awk '{print $NF}' | tr -d '\r\n' | ${config.me.desktop.copy}
        ${lib.getExe pkgs.my.noctalia} msg notification-clear-active
      '';

      nixpkgs.config.permittedInsecurePackages = [
        "python3.12-ecdsa-0.19.2"
      ];
    };
}
