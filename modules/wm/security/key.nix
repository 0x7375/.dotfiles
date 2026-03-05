{
  config,
  inputs,
  mkNixos,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable (
  mkNixos (
    lib.mkMerge [
      {
        services.udev.packages = [ pkgs.yubikey-personalization ];

        services.pcscd.enable = true;

        environment.etc.u2f-mappings.text =
          let
            main = "Qn2ON91sm8M17uGRoTgFnoELP1MTC+ZyL50p253vQHV0ceri4A8HMSsUEjWWPWVIiUaNp4Gd6fmpE2sFuBz7lHxbwlKWooCr7k8nO5yzzGRj5GpOJia+OB+1RHYEBBVi,FnLrRtI7tXuSNnBlKdbLGooQBCpc11wQyB8/nWaLZvuMNaL4LPAXgnZ/CUvgG/rRZip9+1f3/FzaHmwdhKhmPg==,es256,+presence";
            backup = "toxmjgOuJ7ZJvtFSVvKtJ62vg+kIvlUPeucS1UpQ/JfUgGKIIHDqRza75HYXl1NK6I1BhYfFdrZyszwO33ohs6kT+wFVhnUhIM1fHJ+yvK8DABBSBGOSjzgmBXpXaxql,Cv3QySgQubnubMF05DY8UTELZW9S29jQDhnzhbqsZtuZgjoMcVMBUZiU9dYlHap4nG20XPw6tO4IGB1DA7gfjQ==,es256,+presence";
          in
          ''
            ${config.me.user}:${main}:${backup}
            root:${main}:${backup}
          '';

        packages = with pkgs; [
          seahorse
          age-plugin-fido2-hmac
        ];

        security.pam = {
          u2f = {
            enable = true;
            settings = {
              cue = true;
              cue_prompt = ":: Touch the key!";
              authfile = config.environment.etc.u2f-mappings.source;
              origin = "pam://yubikey";
              appid = "pam://yubikey";
            };
          };
          services =
            let
              config = {
                u2fAuth = true;
                unixAuth = false;
              };
            in
            {
              login = config;
              sudo = config;
              polkit-1 = config;
              su = config;
            };
        };
      }
      (lib.mkIf config.me.secrets.enable {
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
    ]
  )
)
