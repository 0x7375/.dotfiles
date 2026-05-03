{ self, ... }:

{
  flake.nixos.desktop =
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

      me.desktop.bindings."Mod+u" =
        let
          mkToast = self.lib.noctalia.mkToast { inherit pkgs lib; };
          call = self.lib.noctalia.call { inherit pkgs lib; };
        in
        pkgs.writeShellScript "totp-menu" ''
          tokens=$(${lib.getExe pkgs.token2-cli} get_all 2>&1 | grep -iv "touch")
          selected=$(echo "$tokens" | awk -F'] | - ' '{print $2}' | ${lib.getExe pkgs.my.dmenu} -p "TOTP")

          [ -z "$selected" ] && exit 0

          app="''${selected%% / *}"
          account="''${selected#* / }"

          ${mkToast {
            title = "Security key";
            body = "Touch required";
            icon = "fingerprint";
            duration = self.lib.noctalia.infinite;
          }}
          ${lib.getExe pkgs.token2-cli} read_entry --app-name "$app" --account-name "$account" 2>&1 | tail -n 1 | awk '{print $NF}' | tr -d '\r\n' | ${config.me.desktop.copy}
          ${call "toast dismiss"}
        '';

      nixpkgs.config.permittedInsecurePackages = [
        "python3.12-ecdsa-0.19.1"
      ];
    };
}
