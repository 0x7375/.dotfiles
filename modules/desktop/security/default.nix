{
  flake.modules.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    {
      persistUser.directories = [
        ".gnupg"
        ".password-store"
      ];

      xdg.desktopEntries.bitwarden = {
        exec = "${lib.getExe pkgs.helium} --app=http://vault.bitwarden.com";
        name = "Bitwarden";
        type = "Application";
      };

      me.desktop =
        let
          type = "appid";
          name = "vault.bitwarden.com";
        in
        {
          assign = [
            {
              inherit name type;
              workspace = "2";
            }
          ];
          floating = [
            {
              inherit name type;
              enable = false;
            }
          ];
        };
    };
}
