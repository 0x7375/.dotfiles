{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
in
pkgs.writeShellApplication {
  name = "swap-theme";
  bashOptions = [ "nounset" ];
  excludeShellChecks = [ "SC2034" ];
  runtimeInputs =
    with pkgs;
    [
      procps
      fd
    ]
    ++ lib.optionals (config.me.wm.displayServer == "xorg") (
      with pkgs;
      [
        i3
        dunst
        xorg.xrdb
      ]
    )
    ++ lib.optionals (config.me.wm.displayServer != "macos") (with pkgs; [ darkman ]);
  text =
    let
      inherit (config.me.wm) theme iconTheme;
    in
    # bash
    ''
      themes_dir="$HOME/.local/state/tinted"
      share_dir="$HOME/.local/share"
      theme_file="''${themes_dir}/theme"

      # default to dark
      [[ -f "$theme_file" ]] || echo "dark" > "$theme_file"

      theme=light
      theme_bool=false

      current_theme=$(< "$theme_file")

      case ''${1:-} in
        sync)
          theme=light
          defaults read -g AppleInterfaceStyle &>/dev/null && theme=dark
          ;;
        light|dark)
          [[ $1 == "$current_theme" ]] && exit 0
          theme=$1
          ;;
        *)
          [[ $current_theme == light ]] && theme=dark || theme=light
          ;;
      esac

      echo "$theme" > "$theme_file"
      [[ "$theme" == "dark" ]] && theme_bool="true"

      fd --hidden ".*-dark" "$themes_dir" | while read -r dark_file; do
        base_path="''${dark_file%-dark}"
        config_path="''${base_path#"$themes_dir"/}"
        mkdir -p "$(dirname "$HOME/$config_path")"
        ln -sf "''${base_path}-''${theme}" "$HOME/$config_path"
      done

      (
        export XDG_CACHE_HOME="${config.vars.XDG_CACHE_HOME}"
        cd "${pkgs.emptyDirectory}" || exit
        ${lib.getExe pkgs.bat} cache --build > /dev/null 2>&1
      )

      ${lib.optionalString (!isDarwin)
        # bash
        ''
          mkdir -p "$share_dir/icons" "$share_dir/themes"
          ln -sfT "${theme.package}/share/themes/${theme.name}-''${theme^}" "$share_dir/themes/${theme.name}"
          ln -sfT "${iconTheme.package}/share/icons/${iconTheme.name}-''${theme^}" "$share_dir/icons/${iconTheme.name}"

          xrdb -load "$HOME/.config/X11/xresources"
          sleep .5

          darkman set "$theme"
          dunstctl reload
          i3-msg restart
        ''
      }

      ${lib.optionalString isDarwin
        # bash
        ''
          [[ ''${1:-} != "sync" ]] &&  osascript -e "tell app \"System Events\" to tell appearance preferences to set dark mode to ''${theme_bool}"
        ''
      }

      pkill -USR1 nvim
    '';
}
