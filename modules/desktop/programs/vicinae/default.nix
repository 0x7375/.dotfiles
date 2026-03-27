{
  flake.nixos.desktop =
    {
      pkgs,
      config,
      inputs,
      secrets,
      lib,
      ...
    }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;

      shortcuts = [
        {
          name = "YouTube";
          alias = "!y";
          url = "https://www.youtube.com/results?search_query=$query";
        }
        {
          name = "Google";
          alias = "!g";
          url = "https://google.com/search?q=$query";
        }
        {
          name = "Google Images";
          alias = "!gi";
          url = "https://google.com/search?q=$query&tbm=isch";
        }
        {
          name = "Startpage";
          alias = "!s";
          url = "https://startpage.com/do/dsearch?prfe=d7a6edf2bdae7d159fd3c7281470fb1b1611b9ebc58099d433766aab83750a24485b18c6615e9979c5ef4f823efb2326568630359a4cfaca9f87b8eda4b78324a831f096405c6b39160f84ca&query=$query";
        }
        {
          name = "Brave";
          alias = "!b";
          url = "https://search.brave.com/search?q=$query";
        }
        {
          name = "Brave Images";
          alias = "!bi";
          url = "https://search.brave.com/images?q=$query";
        }
        {
          name = "MyNixOS Packages";
          alias = "!p";
          url = "https://mynixos.com/search?q=package+$query";
        }
        {
          name = "MyNixOS Options";
          alias = "!o";
          url = "https://mynixos.com/search?q=option+$query";
        }
        {
          name = "Noogle";
          alias = "!n";
          url = "https://noogle.dev/q?term=$query";
        }
        {
          name = "Nix Packages History";
          alias = "!u";
          url = "https://history.nix-packages.com/search?search=$query";
        }
        {
          name = "GitHub";
          alias = "!h";
          url = "https://github.com/search?type=code&q=$query";
        }
        {
          name = "Wikipedia";
          alias = "!w";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=$query";
        }
        {
          name = "Bescherelle";
          alias = "!c";
          url = "https://conjugaison.bescherelle.com/verbes/$query";
        }
        {
          name = "Youtube";
          alias = "y";
          url = "https://youtube.com";
        }
        {
          name = "Youtube";
          alias = "y";
          url = "https://youtube.com";
        }
        {
          name = "Monkeytype";
          alias = "mo";
          url = "https://monkeytype.com";
        }
        {
          name = "Twitch";
          alias = "t";
          url = "https://twitch.tv/directory/following";
        }
        {
          name = "Webmail";
          alias = "w";
          url = "https://webmail.unicaen.fr/#1";
        }
        {
          name = "Ecampus";
          alias = "e";
          url = "https://ecampus-vert.unicaen.fr/my/courses.php";
        }
        {
          name = "Tutanota";
          alias = "ma";
          url = "https://app.tuta.com/login";
        }
        {
          name = "Addy";
          alias = "a";
          url = "https://addy.io";
        }
        {
          name = "Send";
          alias = "se";
          url = "https://send.vis.ee/";
        }
        {
          name = "Devhints";
          alias = "dh";
          url = "https://devhints.io/";
        }
      ];

      sqlValues = lib.concatMapStringsSep ",\n" (
        s:
        let
          urlMatch = builtins.match "^https?://([^/]+)(/.*)?$" s.url;
          host = s.iconHost or (if urlMatch != null then builtins.elemAt urlMatch 0 else "example.com");

          browser = "${config.me.desktop.browser}.desktop";
          queryArg = "{argument name=\"Query\"}";
          finalUrl =
            if lib.hasInfix "$query" s.url then
              builtins.replaceStrings [ "$query" ] [ queryArg ] s.url
            else
              s.url;

          iconUrl = "icon://favicon/${host}?fallback=icon://omnicast/image?fill%3Dprimary-text";
        in
        "('shortcut-${s.alias}', '${s.name}', '${iconUrl}', '${finalUrl}', '${browser}', 0, 0, 0, 0)"
      ) shortcuts;

      shortcutProviders = {
        shortcuts.entrypoints = builtins.listToAttrs (
          map (s: {
            name = "shortcut-${s.alias}";
            value = {
              alias = s.alias;
            };
          }) shortcuts
        );
      };

      vicinaeServerWrapper = pkgs.writeShellScript "vicinae-server" ''
        DB_PATH="$HOME/.local/share/vicinae/vicinae.db"
        mkdir -p "$(dirname "$DB_PATH")"

        ${lib.getExe pkgs.sqlite} "$DB_PATH" "
          CREATE TABLE IF NOT EXISTS shortcut (id TEXT PRIMARY KEY, name TEXT, icon TEXT, url TEXT, app TEXT, open_count INTEGER, created_at INTEGER, updated_at INTEGER, last_used_at INTEGER);
          
          INSERT OR IGNORE INTO shortcut 
            (id, name, icon, url, app, open_count, created_at, updated_at, last_used_at) 
          VALUES 
            ${sqlValues};
        "

        exec ${lib.getExe pkgs.vicinae} server
      '';

      extensions =
        with inputs.vicinae-extensions.packages.${system};
        [
          bluetooth
          nix
          wifi-commander
          process-manager

          # TODO: check upstream if it stops being blacklisted
          # systemd
        ]
        ++ [
          (inputs.vicinae.packages.${system}.mkVicinaeExtension {
            name = "powermenu";
            version = "1.0.0";
            src = ./extensions/powermenu;
          })
        ]
        ++ (with inputs.vicinae.packages.${system}; [
          (mkRayCastExtension {
            name = "gif-search";
            sha256 = "sha256-G7il8T1L+P/2mXWJsb68n4BCbVKcrrtK8GnBNxzt73Q=";
            rev = "4d417c2dfd86a5b2bea202d4a7b48d8eb3dbaeb1";
          })
          (mkRayCastExtension {
            name = "deepcast";
            sha256 = "sha256-Q3vfBX8Js9iRUNoFNPInnUCRClrBsWI00EDdz6A4ayI=";
            rev = "1299394665c6a4ac24e2076d9421268f6445acd0";
          })
        ]);

      theme = "nix";
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          # TODO: until unstable has v0.20.8
          vicinae = final.auto.vicinae.overrideAttrs (old: {
            src = final.fetchFromGitHub {
              owner = "vicinaehq";
              repo = "vicinae";
              tag = "v0.20.8";
              hash = "sha256-G+ibcIvOaPE3qot4zLmHUo7cmNFNU1kw2Zhn08D26Ts=";
            };
          });
        })
      ];

      packages = [ pkgs.vicinae ];

      me.desktop =
        let
          vicinae = lib.getExe pkgs.vicinae;
        in
        {
          bindings =
            let
              dir = "$HOME/notes";
              openNote =
                pkgs.writeShellScript "open-note"
                  # bash
                  ''
                    note=$(ls ${dir} | sed 's/\.md$//' | ${vicinae} dmenu --no-quick-look -p "NOTE")
                    [ -n "$note" ] && $TERMINAL $EDITOR "${dir}/$note.md"
                  '';
            in
            {
              "Mod+d" = "${vicinae} open";
              "Mod+p" = "${vicinae} vicinae://launch/@me/powermenu/index";
              "Mod+b" = "${vicinae} vicinae://launch/@Gelei/vicinae-extension-bluetooth-0/devices";
              "Mod+m" = openNote;
              "Mod+n" =
                "${vicinae} vicinae://launch/@dagimg-dot/vicinae-extension-wifi-commander-0/manage-saved-networks";
              "Mod+Shift+b" = pkgs.writeShellScript "open-bookmark" ''
                file="$HOME/notes/Bookmarks.md"
                [[ ! -f $file ]] && exit

                selection=$(awk -F': ' '{print $1}' "$file" | vicinae dmenu --no-quick-look -p "BOOKMARK")
                [[ -z "$selection" ]] && exit

                url=$(awk -F': ' -v sel="$selection" '$1 == sel {print $2}' "$file")

                [[ -n "$url" ]] && ${config.me.desktop.open} "$url"
              '';
            };
          startup = {
            autocutsel = "${lib.getExe pkgs.autocutsel} -fork";
            vicinae = toString vicinaeServerWrapper;
          };
        };

      sops.secrets.vicinae = {
        sopsFile = "${secrets}/vicinae.json";
        format = "json";
        key = "";
        owner = config.me.user;
      };

      hj.files =
        builtins.listToAttrs (
          map (ext: {
            name = ".local/share/vicinae/extensions/${ext.name}";
            value.source = ext;
          }) extensions
        )
        // {
          ".config/vicinae/settings.json" = {
            generator = lib.generators.toJSON { };
            value = {
              imports = [ config.sops.secrets.vicinae.path ];

              close_on_focus_loss = true;

              keybinding = "emacs";
              keybinds = {
                # leave ctrl+p for previous
                "open-search-filter" = "super+control+shift+P";
              };

              pop_to_root_on_close = true;
              font = {
                rendering = "native";
                normal.family = config.me.desktop.font.family;
              };
              theme = {
                enabled = false;
                light.name = theme;
                dark.name = theme;
              };
              escape_key_behavior = "close_window";

              launcher_window = {
                blur.enabled = false;
                opacity = 1;
                dim_around = false;

                size = {
                  width = 924;
                  height = 576;
                };

                client_side_decorations = {
                  enabled = true;
                  rounding = 0;
                };

                layer_shell.enabled = true;
              };

              providers = {
                applications.preferences = {
                  defaultAction = "launch";
                  launchPrefix = "uwsm app --";
                };

                browser-extension.enabled = false;

                "@dagimg-dot/vicinae-extension-wifi-commander-0".entrypoints = {
                  scan-wifi.alias = "ns";
                  restart-wifi.enabled = false;
                  toggle-wifi-on.enabled = false;
                  toggle-wifi-off.enabled = false;
                  manage-saved-networks.alias = "nm";
                };

                "@knoopx/store.vicinae.systemd".entrypoints = {
                  services.alias = "s";
                };
                # TODO: use this
                # "@knoopx/vicinae-extension-systemd-0".entrypoints = {
                #   services.alias = "s";
                # };

                "@Gelei/vicinae-extension-bluetooth-0" = {
                  preferences.connectionToggleable = true;
                  entrypoints = {
                    devices.alias = "bd";
                    discoverable.enabled = false;
                    bluetooth-on.enabled = false;
                    bluetooth-off.enabled = false;
                    scan.alias = "bs";
                  };
                };

                "@leonkohli/vicinae-extension-process-manager-0" = {
                  preferences = {
                    refresh-interval = "3000";
                    sort-by-memory = true;
                  };
                  entrypoints = {
                    processes.alias = "k";
                    kill.enabled = false;
                  };
                };

                "@josephschmitt/gif-search".entrypoints = {
                  search.alias = "gif";
                };

                "@knoopx/vicinae-extension-nix-0".entrypoints = {
                  home-manager-options.alias = "hm";
                  packages.alias = "pk";
                  pull-requests.alias = "pr";
                  options.alias = "o";
                  flake-packages.enabled = false;
                };

                developer.enabled = false;

                system.enabled = false;

                calculator.entrypoints = {
                  refresh-rates.enabled = false;
                  history.alias = "c";
                };

                power.enabled = false;

                files = {
                  preferences = {
                    excludedPaths = ".venv;.git;.direnv";
                  };
                  entrypoints.search.alias = "f";
                };

                clipboard = {
                  entrypoints.history.alias = "c";
                  # preferences.encryption = true;
                };

                core.entrypoints = {
                  join-discord-server.enabled = false;
                  keybind-settings.enabled = false;
                  manage-fallback.enabled = false;
                  report-bug.enabled = false;
                  sponsor.enabled = false;
                  open-default-config.enabled = false;
                  open-config-file.enabled = false;
                  prune-memory.enabled = false;
                  reload-scripts.enabled = false;
                  search-builtin-icons.enabled = false;
                  list-extensions.enabled = false;
                  documentation.enabled = false;
                  about.enabled = false;
                };

                "@mooxl/deepcast".entrypoints = {
                  englishUS.alias = "te";
                  french.alias = "tf";

                  arabic.enabled = false;
                  finnish.enabled = false;
                  estonian.enabled = false;
                  englishUK.enabled = false;
                  dutch.enabled = false;
                  danish.enabled = false;
                  czech.enabled = false;
                  bulgarian.enabled = false;
                  chinese.enabled = false;
                  german.enabled = false;
                  greek.enabled = false;
                  hungarian.enabled = false;
                  index.enabled = false;
                  indonesian.enabled = false;
                  italian.enabled = false;
                  japanese.enabled = false;
                  latvian.enabled = false;
                  lithuanian.enabled = false;
                  norwegian.enabled = false;
                  polish.enabled = false;
                  portuguese.enabled = false;
                  portugueseBrazil.enabled = false;
                  romanian.enabled = false;
                  russian.enabled = false;
                  korean.enabled = false;
                  slovak.enabled = false;
                  slovenian.enabled = false;
                  spanish.enabled = false;
                  swedish.enabled = false;
                  turkish.enabled = false;
                  ukrainian.enabled = false;
                };
              }
              // shortcutProviders;
            };
          };
        };

      tinted.files.".local/share/vicinae/themes/${theme}.toml".text =
        p:
        # ini
        ''
          [meta]
          version = 1
          name = "${theme}"
          description = "Automatically generated theme by nix"
          variant = "${p._theme}"

          [colors.core]
          background = "${p.bg0_dark}"
          foreground = "${p.fg1}"
          secondary_background = "${p.bg0}"
          border = "${p.bg2}"
          accent = "${p.bg1}"

          [colors.accents]
          blue = "${p.blue}"
          green = "${p.green}"
          magenta = "${p.magenta}"
          orange = "${p.orange}"
          purple = "${p.magenta}"
          red = "${p.red}"
          yellow = "${p.yellow}"
          cyan = "${p.cyan}"

          [colors.list.item.selection]
          background = "${p.bg1}"
          secondary_background = "${p.bg1}"

          [colors.grid.item]
          background = "${p.bg1}"
        '';
    };
}
