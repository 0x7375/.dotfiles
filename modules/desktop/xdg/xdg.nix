{
  flake.lib.mapMimeEntries =
    list: desktopEntry:
    builtins.listToAttrs (
      map (mimetype: {
        name = mimetype;
        value = desktopEntry + ".desktop";
      }) list
    );

  flake.nixos.desktop =
    {
      pkgs,
      ...
    }:
    {
      xdg.mimeApps.defaultApplications.enable = true;

      xdg.desktopEntries = {
        modrinth = {
          exec = "env WEBKIT_DISABLE_DMABUF_RENDERER=1 modrinth-app";
          name = "Minecraft";
          type = "Application";
          categories = [ "Game" ];
        };
      };

      xdg.portal = {
        enable = true;
        config.common."org.freedesktop.impl.portal.Settings" = "darkman";
        extraPortals = with pkgs; [ darkman ];
      };

      hj.xdg.config.files."darkman/config.yaml".text = "usegeoclue: false";
    };
}
