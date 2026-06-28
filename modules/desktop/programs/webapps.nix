{
  flake.modules.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    let
      yt-id = "cinhimbnkkaeohfgghhklpknlkffjgod";
    in
    {
      xdg.desktopEntries = {
        youtube-music = {
          exec = "${lib.getExe pkgs.helium} --app-id=${yt-id}";
          name = "YouTube Music";
          type = "Application";
          icon = "chrome-${yt-id}-Default";
        };

        discord = {
          exec = "${lib.getExe pkgs.helium} --app=https://discord.com/channels/@me";
          name = "Discord";
          type = "Application";
          icon = "discord";
        };

        bitwarden = {
          exec = "${lib.getExe pkgs.helium} --app=http://vault.bitwarden.com";
          name = "Bitwarden";
          type = "Application";
          icon = "bitwarden";
        };
      };

      me.desktop =
        let
          type = "appid";
        in
        {
          assign = [
            {
              inherit type;
              name = "vault.bitwarden.com";
              workspace = "2";
            }
            {
              inherit type;
              name = "chrome-discord.com__channels_@me-Default";
              workspace = "4";
            }
            {
              inherit type;
              name = "chrome-${yt-id}-Default";
              workspace = "4";
            }
          ];
          floating = [
            {
              inherit type;
              name = "vault.bitwarden.com";
              enable = false;
            }
          ];
        };
    };
}
