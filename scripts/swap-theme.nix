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
    theme_file=~/.local/state/current_theme

    if [[ $(< $theme_file) == "dark" ]]; then
      echo "light" > $theme_file
    else
      echo "dark" > $theme_file
    fi

    theme=$(< $theme_file)

    ln -s -f "$HOME/.config/alacritty/''${theme}.toml" "$HOME/.config/alacritty/theme.toml"
    ln -s -f "$HOME/.config/waybar/''${theme}.css" "$HOME/.config/waybar/theme.css"
    ln -s -f "$HOME/.config/X11/''${theme}" "$HOME/.config/X11/xresources"
    ln -s -f "$HOME/.config/gtk-4.0/''${theme}.css" "$HOME/.config/gtk-4.0/gtk.css"
    ln -s -f "$HOME/.config/dunst/dunstrc.d/''${theme}" "$HOME/.config/dunst/dunstrc.d/theme.conf"

    xrdb -load "$HOME/.config/X11/xresources"

    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-''${theme}'"

    dunstctl reload
    i3-msg restart
    pkill nautilus
    pkill -USR1 nvim
  '';
}
