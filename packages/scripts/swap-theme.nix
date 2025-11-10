{
  pkgs,
  ...
}:

pkgs.writeShellApplication {
  name = "swap-theme";
  bashOptions = [ "nounset" ];
  runtimeInputs = with pkgs; [
    procps
    systemd
  ];
  text = ''
    themes_dir=~/.local/state/tinted
    theme_file="''${themes_dir}/theme"

    theme=
    if [[ $(< $theme_file) == "dark" ]]; then
      theme=light
    else
      theme=dark
    fi

    echo "$theme" > "$theme_file"

    fd --hidden ".*-dark" "$themes_dir" | while read -r dark_file; do
      base_path="''${dark_file%-dark}"
      config_path="''${base_path#"$themes_dir"/}"
      ln -sf "''${base_path}-''${theme}" "$HOME/$config_path"
    done

    xrdb -load "$HOME/.config/X11/xresources"
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-''${theme}'"
    dunstctl reload
    i3-msg restart
    pkill nautilus
    pkill -USR1 nvim
  '';
}
