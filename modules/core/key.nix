{
  config,
  mkNixos,
  pkgs,
  lib,
  ...
}:

mkNixos {
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

  packages = [ pkgs.age-plugin-fido2-hmac ];

  security.pam = {
    rssh.enable = true;
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
    services = lib.genAttrs [ "sudo" "su" "login" "polkit-1" ] (_: {
      rssh = true;
      u2fAuth = true;
      unixAuth = false;
    });
  };
}
