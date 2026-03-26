{ self, ... }:

{
  flake.nixos.desktop =
    { config, ... }:
    {
      xdg.mimeApps.defaultApplications =
        let
          inherit (self.lib) mimeMapEntries;
          inherit (config.me.desktop) browser;
        in
        {
          defaultApplications = mimeMapEntries [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/chrome"
            "x-scheme-handler/mailto"
          ] browser;

          associations.added = mimeMapEntries [
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/chrome"
          ] browser;
        };
    };

  flake.shared.desktop =
    {
      pkgs,
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
                type = "class";
                name = browserPascalCase;
                workspace = "3";
              }
            ];

          bindings = {
            "Mod+w" = config.me.desktop.browser;
            "Mod+b" = pkgs.writeShellScript "open bookmark" ''
              file="$HOME/notes/Bookmarks.md"
              [[ ! -f $file ]] && exit

              selection=$(awk -F': ' '{print $1}' "$file" | vicinae dmenu --no-quick-look -p "BOOKMARK")
              [[ -z "$selection" ]] && exit

              url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")

              [[ -n "$url" ]] && ${config.me.desktop.open} "$url"
            '';
          };
        };
      };
    };
}
