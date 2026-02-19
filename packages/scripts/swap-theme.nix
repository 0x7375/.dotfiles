{
  lib,
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
  text = ''
    themes_dir="$HOME/.local/state/tinted"
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

    ${lib.optionalString (!isDarwin) ''
      xrdb -load "$HOME/.config/X11/xresources"
      dconf write /org/gnome/desktop/interface/color-scheme "'prefer-''${theme}'"
      dunstctl reload
      i3-msg restart
      pkill nemo
    ''}

    ${lib.optionalString isDarwin ''
      [[ ''${1:-} != "sync" ]] &&  osascript -e "tell app \"System Events\" to tell appearance preferences to set dark mode to ''${theme_bool}"
    ''}

    pkill -USR1 nvim
  '';
}
