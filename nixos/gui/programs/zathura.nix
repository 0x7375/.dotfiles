{
  pkgs,
  myLib,
  config,
  lib,
  ...
}:

lib.mkIf config.me.gui.enable {
  packages = with pkgs; [ zathura ];

  xdg.desktopEntries.zaread = {
    name = "Zaread";
    exec = "zaread %F";
    terminal = false;
    categories = [
      "Office"
      "Viewer"
    ];
  };

  tinted.files.".config/zathura/zathurarc".text = palette: ''
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

    # Smooth scrolling
    map j feedkeys "<C-Down>"
    map k feedkeys "<C-Up>"
    map h feedkeys "<C-Left>"
    map l feedkeys "<C-Right>"

    map R reload
    map [index] <C-m> navigate_index select
    map b navigate previous
    map d scroll half-down
    map f navigate next
    map i recolor
    map r reload
    map u scroll half-up

    set recolor-darkcolor	"${palette.fg0}"
    set recolor-lightcolor	"${palette.bg0}"

    set completion-bg	"${palette.bg2}"
    set completion-fg	"${palette.fg0}"
    set completion-group-bg	"${palette.bg1}"
    set completion-group-fg	"${palette.fg4}"
    set completion-highlight-bg	"${palette.blue}"
    set completion-highlight-fg	"${palette.bg2}"

    set default-bg	"${palette.bg0}"
    set default-fg	"${palette.fg0}"

    set highlight-active-color	"rgba(254,128,25,0.5)"
    set highlight-color	"rgba(250,189,47,0.5)"

    set index-active-bg	"${palette.blue}"
    set index-active-fg	"${palette.bg2}"
    set index-bg	"${palette.bg2}"
    set index-fg	"${palette.fg0}"

    set inputbar-bg	"${palette.bg0}"
    set inputbar-fg	"${palette.fg0}"

    set notification-bg	"${palette.bg0}"
    set notification-error-bg	"${palette.bg0}"
    set notification-error-fg	"${palette.red}"
    set notification-fg	"${palette.green}"
    set notification-warning-bg	"${palette.bg0}"
    set notification-warning-fg	"${palette.yellow}"

    set render-loading-bg	"${palette.bg0}"
    set render-loading-fg	"${palette.fg0}"

    set statusbar-bg	"${palette.bg2}"
    set statusbar-fg	"${palette.fg0}"
  '';
}
