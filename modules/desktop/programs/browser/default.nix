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
            "Mod+b" = "${pkgs.writeShellScript "open bookmark" ''
              file="$HOME/notes/Bookmarks.md"
              [[ ! -f $file ]] && exit

              selection=$(awk -F': ' '{print $1}' "$file" | vicinae dmenu --no-quick-look -p "BOOKMARK")
              [[ -z "$selection" ]] && exit

              if [[ $selection == !* ]]; then
                bang="''${selection%% *}"
                query="''${selection#* }"
                query="''${query// /+}"
                
                case "$bang" in
                  "!y") url="https://www.youtube.com/results?search_query=$query" ;;
                  "!g") url="https://google.com/search?q=$query" ;;
                  "!gi") url="https://google.com/search?q=$query&tbm=isch" ;;
                  "!s") url="https://www.startpage.com/do/dsearch?prfe=d7a6edf2bdae7d159fd3c7281470fb1b1611b9ebc58099d433766aab83750a24485b18c6615e9979c5ef4f823efb2326568630359a4cfaca9f87b8eda4b78324a831f096405c6b39160f84ca&query=$query" ;;
                  "!b") url="https://search.brave.com/search?q=$query" ;;
                  "!bi") url="https://search.brave.com/images?q=$query" ;;
                  "!p") url="https://mynixos.com/search?q=package+$query" ;;
                  "!o") url="https://mynixos.com/search?q=option+$query" ;;
                  "!n") url="https://noogle.dev/q?term=$query" ;;
                  "!u") url="https://history.nix-packages.com/search?search=$query" ;;
                  "!h") url="https://github.com/search?type=code&q=$query" ;;
                  "!w") url="https://en.wikipedia.org/wiki/Special:Search?search=$query" ;;
                  "!c") url="https://conjugaison.bescherelle.com/verbes/$query" ;;
                  *) url="https://google.com/search?q=$query" ;;
                esac
              else
                url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")
              fi

              [[ -n "$url" ]] && ${config.me.desktop.open} "$url"
            ''}";
          };
        };
      };
    };
}
