{
  flake.lib.mapMimeEntries =
    list: desktopEntry:
    builtins.listToAttrs (
      map (mimetype: {
        name = mimetype;
        value = desktopEntry + ".desktop";
      }) list
    );

  flake.modules.nixos.desktop = {
    xdg.mimeApps.enable = true;

    xdg.desktopEntries = {
      modrinth = {
        exec = "env WEBKIT_DISABLE_DMABUF_RENDERER=1 modrinth-app";
        name = "Minecraft";
        type = "Application";
        categories = [ "Game" ];
      };
    };

    xdg.portal.enable = true;
  };
}
