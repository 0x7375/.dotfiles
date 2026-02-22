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
  runtimeInputs = with pkgs; [
    procps
    fd
  ];
  text =
    let
      inherit (config.me.wm) theme iconTheme;
    in
    # bash
    ''
      themes_dir="$HOME/.local/state/tinted"
      share_dir="$HOME/.local/share"
      theme_file="''${themes_dir}/theme"

      [[ -f "$theme_file" ]] || echo "dark" > "$theme_file"

      theme=light
      theme_bool=false
      if [[ ''${1:-} == "sync" ]]; then
        if defaults read -g AppleInterfaceStyle &>/dev/null; then theme=dark; fi 
      elif [[ ''${1:-} =~ ^(light|dark)$ ]]; then
        theme=$1
      else
        [[ $(< "$theme_file") == "light" ]] && theme=dark
      fi

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
