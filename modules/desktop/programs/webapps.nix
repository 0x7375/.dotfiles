{
  flake.modules.nixos.desktop =
    {
      pkgs,
      lib,
      ...
    }:
    {
      xdg.desktopEntries.youtube-music = {
        exec = "${lib.getExe pkgs.helium} --profile-directory=YoutubeMusic --app=http://music.youtube.com";
        name = "Youtube Music";
        type = "Application";
      };

      xdg.desktopEntries.discord = {
        exec = "${lib.getExe pkgs.helium} --app=https://discord.com/channels/@me";
        name = "Discord";
        type = "Application";
      };

      me.desktop.assign =
        let
          type = "appid";
        in
        [
          {
            inherit type;
            name = "chrome-discord.com__channels_@me-Default";
            workspace = "4";
          }
          {
            inherit type;
            name = "chrome-music.youtube.com__-Default";
            workspace = "4";
          }
        ];
    };
}
