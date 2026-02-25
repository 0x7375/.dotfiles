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
      pam_u2f = (prev.crossPkgs or prev).pam_u2f.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace util.h \
            --replace-fail "Please touch the FIDO authenticator." "\033[34m::\033[0m Touch the key!"
        '';
      });
    })
  ];

  services.udev.packages = [ pkgs.yubikey-personalization ];
  packages = with pkgs; [
    yubioath-flutter
    yubikey-manager
  ];

  services.pcscd.enable = true;

  environment.etc.u2f-mappings.text =
    let
      main = "YdXi/3GR49vmWnA9K4FupHaUQo7x2LQi98fllT3UCDAPBOD/jVkwR3BLOnIN2YM0Wb6Ux54GJVXxZYPTA8j6sET8Z+8Nzu5qctuN+3c2rTbRRezMnxMX10DcpAbQwljH,98547XlxcGQ90xDtHBxHUx6CwXMIsfGwhkUkN3ZT450586/fJa0aHtmWQD0mRgcd9WEHGNKzGbTDFO8N1G2XeQ==,es256,+presence";
      backup = "U2oUgvA+MJdKClbVJx9CZZp7OA1+hgzDJjVkhXJDz6WyP+WFY/oPoN/wnlQT3X33u2y2KL0LBYcPYY76Xf718Bq4cmc0B86PlLz3+7mDRXrLB2gDJ67wVReiGzRpMJ1V,0SL7k3nc0obDrUuW+hPeAl5pbMAtzvFdh4KlDKATUPm0OXvM9Qiv+eJb6AffTUIDAd4sy9pDGmzfk+70inMBLw==,es256,+presence";
    in
    ''
      ${config.me.user}:${main}:${backup}
      root:${main}:${backup}
    '';

  security.pam = {
    u2f = {
      enable = true;
      settings = {
        cue = true;
        authfile = config.environment.etc.u2f-mappings.source;
      };
    };
    services = {
      login = {
        u2fAuth = true;
        unixAuth = true;
      };
      sudo = {
        u2fAuth = true;
        unixAuth = false;
      };
    };
  };
})
