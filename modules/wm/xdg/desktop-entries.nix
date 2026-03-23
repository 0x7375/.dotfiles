{
  mkNixos,
  lib,
  config,
  ...
}:

lib.mkIf config.me.wm.enable (mkNixos {
  xdg.desktopEntries = {
    modrinth = {
      exec = "env WEBKIT_DISABLE_DMABUF_RENDERER=1 modrinth-app";
      name = "Minecraft";
      type = "Application";
      categories = [ "Game" ];
    };
  };
})
