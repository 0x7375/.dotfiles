{
  pkgs,
  myLib,
  config,
  lib,
  ...
}:

let
  theme =
    isDark:
    let
      p = myLib.palette;
      color =
        let
          choose = dark: light: if isDark then dark else light;
        in
        {
          fg = choose p.fg0 p.bg0;
          bg = choose p.bg0 p.fg0;
          alt-fg = choose p.fg4 p.bg3;
          alt-bg = choose p.bg2 p.fg3;
          alt-alt-bg = choose p.bg1 p.fg2;
        };
    in
    # zathurarc
    ''
      set recolor-darkcolor	"${color.fg}"
      set recolor-lightcolor	"${color.bg}"

      set completion-bg	"${color.alt-bg}"
      set completion-fg	"${color.fg}"
      set completion-group-bg	"${color.alt-alt-bg}"
      set completion-group-fg	"${color.alt-fg}"
      set completion-highlight-bg	"${p.blue}"
      set completion-highlight-fg	"${color.alt-bg}"

      set default-bg	"${p.bg0_dark}"
      set default-fg	"${color.fg}"

      set highlight-active-color	"rgba(254,128,25,0.5)"
      set highlight-color	"rgba(250,189,47,0.5)"

      set index-active-bg	"${p.blue}"
      set index-active-fg	"${color.alt-bg}"
      set index-bg	"${color.alt-bg}"
      set index-fg	"${color.fg}"

      set inputbar-bg	"${color.bg}"
      set inputbar-fg	"${color.fg}"

      set notification-bg	"${color.bg}"
      set notification-error-bg	"${color.bg}"
      set notification-error-fg	"${p.red}"
      set notification-fg	"${p.green}"
      set notification-warning-bg	"${color.bg}"
      set notification-warning-fg	"${p.yellow}"

      set render-loading-bg	"${color.bg}"
      set render-loading-fg	"${color.fg}"

      set statusbar-bg	"${color.alt-bg}"
      set statusbar-fg	"${color.fg}"
      ${if isDark then "# dark mode true" else ""}
    '';
  rc =
    let
      swap-zathura-theme = pkgs.writeShellScript "swap-zathura-theme" ''
        if tail -n 1 ~/.config/zathura/zathurarc | grep -q dark ; then
          cp -f ~/.config/zathura/zathurarc-light ~/.config/zathura/zathurarc
        else
          cp -f ~/.config/zathura/zathurarc-dark ~/.config/zathura/zathurarc
        fi
      '';
    in
    # zathurarc
    ''
      set guioptions "none"

      # dark mode by default
      set recolor "true"

      # keep images/graphes default color
      # set recolor-keephue "true"

      set render-loading "true"

      set scroll-full-overlap	"0.01"
      set scroll-step	"100"

      set selection-clipboard	"clipboard"
      set selection-notification "false"

      set statusbar-h-padding	"0"
      set statusbar-v-padding	"0"

      map <C-I> feedkeys ":exec '${swap-zathura-theme}'"<Return>:source<Return>
      map <C-N> exec 'zathura "$FILE"'
      map <C-j> navigate next
      map <C-k> navigate previous
      map <C-p> print
      map <C-r> rotate
      map <Left> navigate previous
      map <Right> navigate next
      map D toggle_page_mode
      map J zoom out
      map K zoom in
      map R reload
      map [index] <C-m> navigate_index select
      map b navigate previous
      map d scroll half-down
      map f navigate next
      map i recolor
      map r reload
      map u scroll half-up
    '';
in
lib.mkIf config.me.gui.enable {
  home.packages = with pkgs; [
    zathura
    scripts.zaread
  ];

  xdg.desktopEntries.zaread = {
    name = "Zaread";
    exec = "zaread %F";
    terminal = false;
    categories = [
      "Office"
      "Viewer"
    ];
  };

  xdg.configFile."zathura/zathurarc-dark".text = rc + theme true;
  xdg.configFile."zathura/zathurarc-light".text = rc + theme false;

  systemd.user.tmpfiles.rules =
    let
      content = builtins.replaceStrings [ "\n" ] [ "\\n" ] (rc + theme true);
    in
    [
      "f /home/${config.me.user}/.config/zathura/zathurarc 0644 ${config.me.user} users - ${content}"
    ];
}
