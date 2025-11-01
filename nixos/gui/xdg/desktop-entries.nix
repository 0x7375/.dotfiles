{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf config.me.gui.enable {
  xdg.desktopEntries = {
    dofus =
      let
        dofusLauncher = pkgs.fetchurl {
          url = "https://download.ankama.com/launcher-dofus/full/linux";
          sha256 = "sha256-30c+NtcyyUKC8lCmnE8gti76+Y4vTeN7Iph6u4C1/G8=";
          executable = true;
          curlOptsList =
            let
              UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
            in
            [
              "-H"
              ''User-Agent: ${UA}''
            ];
        };

      in
      {
        name = "Dofus";
        exec = "${dofusLauncher}";
        type = "Application";
        categories = [ "Game" ];
      };

    modrinth = {
      exec = "env WEBKIT_DISABLE_DMABUF_RENDERER=1 modrinth-app";
      name = "Minecraft";
      type = "Application";
      categories = [ "Game" ];
    };

    "file-roller" = {
      exec = "file-roller %F";
      name = "File Roller";
    };

    "apache-hop" = {
      exec = "env GTK_THEME=Adwaita:dark hop-gui";
      name = "Apache Hop";
      type = "Application";
      categories = [ "Development" ];
    };
  };
}
