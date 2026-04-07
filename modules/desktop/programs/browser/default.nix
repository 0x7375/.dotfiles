{ self, ... }:

{
  flake.nixos.desktop =
    { config, ... }:
    {
      xdg.mimeApps =
        let
          inherit (self.lib) mapMimeEntries;
          inherit (config.me.desktop) browser;
        in
        {
          defaultApplications = mapMimeEntries [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/chrome"
            "x-scheme-handler/mailto"
          ] browser;

          associations.added = mapMimeEntries [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/chrome"
          ] browser;
        };
    };

  flake.shared.desktop =
    {
      config,
      lib,
      ...
    }:
    {
      options.me.desktop = {
        refreshRate = lib.mkOption {
          type = lib.types.int;
          default = 60;
          description = "Refresh rate (for smooth scrolling settings in zen)";
        };

        browser = lib.mkOption {
          type = lib.types.str;
          default = "helium";
          description = "Default browser";
        };
      };

      config = {
        vars.BROWSER = config.me.desktop.browser;

        me.desktop = {
          assign =
            let
              inherit (config.me.desktop) browser;
              browserPascalCase =
                lib.strings.toUpper (builtins.substring 0 1 browser)
                + builtins.substring 1 ((builtins.stringLength browser) - 1) browser;
            in
            [
              {
                type = "appid";
                name = browserPascalCase;
                workspace = "3";
              }
            ];

          bindings."Mod+w" = config.me.desktop.browser;
        };
      };
    };
}
