# wip
{
  lib,
  config,
  myLib,
  ...
}:

let
  palette = myLib.palette;
in
lib.mkIf config.me.gui.enable {
  nixpkgs.overlays = [
    (final: prev: {
      vesktop = prev.vesktop.overrideAttrs (old: {
        patchPhase =
          (old.patchPhase or "")
          + ''
            rm static/shiggy.gif
            cp ${myLib.fromRoot "assets/nixos-gruvbox.gif"} static/shiggy.gif
            chmod 644 static/shiggy.gif
          '';
      });
    })
  ];

  # home.packages = [ pkgs.vesktop ];

  xdg.configFile."vesktop/themes/nix.theme.css" = {
    enable = false;
    text = # css
      ''
        /**
         * @name Nixos
         * @author Nixos
         * @version 0.0.0
         * @description Theme configured via Home Manager.
         **/

        :root {
          --primary-630: ${palette.bg0}; /* Autocomplete background */
          --green-360: ${palette.cyan};
          --primary-660: ${palette.bg1}; /* Search input background */
          --white-500: ${palette.fg0};

          --brand-100: ${palette.cyan};
          --brand-130: ${palette.cyan};
          --brand-160: ${palette.cyan};
          --brand-200: ${palette.cyan};
          --brand-230: ${palette.cyan};
          --brand-260: ${palette.cyan};
          --brand-300: ${palette.cyan};
          --brand-330: ${palette.cyan};
          --brand-360: ${palette.cyan};
          --brand-400: ${palette.cyan};
          --brand-430: ${palette.cyan};
          --brand-460: ${palette.cyan};
          --brand-500: ${palette.cyan};
          --brand-530: ${palette.cyan};
          --brand-560: ${palette.cyan}80;
          --brand-600: ${palette.cyan}BF;
          --brand-630: ${palette.cyan}BF;
          --brand-660: ${palette.cyan}BF;
          --brand-700: ${palette.cyan};
          --brand-730: ${palette.cyan};
          --brand-760: ${palette.cyan};
          --brand-800: ${palette.cyan};
          --brand-830: ${palette.cyan};
          --brand-860: ${palette.cyan};
          --brand-900: ${palette.cyan};
        }

        .theme-light, .theme-dark {
          --search-popout-option-fade: none; /* Disable fade for search popout */
          --bg-overlay-1: ${palette.bg0}; /* these 2 are needed for proper threads coloring */

          --bg-overlay-2: ${palette.bg1}80; /* sidebar bottom */ 
          --background-secondary-alt: ${palette.bg1}80;

          --button-secondary-background: ${palette.bg1};

          --home-background: red;
          --background-primary: ${palette.bg1};
          --background-secondary: ${palette.bg0_light};
          --channeltextarea-background: ${palette.bg2};
          --background-tertiary: ${palette.bg0}; /* servers */
          --background-accent: yellow;
          --background-floating: ${palette.bg0_dark};
          --background-modifier-hover: ${palette.bg1}; /* 30% of base00 */
          --background-modifier-selected: ${palette.bg2};
          --text-normal: ${palette.fg2};
          --text-secondary: fuchsia;
          --text-muted: ${palette.fg3};
          --text-link: ${palette.cyan};
          --interactive-normal: ${palette.fg1}; /* buttons */
          --interactive-hover: ${palette.fg0};
          --interactive-active: ${palette.fg0};
          --interactive-muted: ${palette.cyan};
          --channels-default: ${palette.fg3};
          --channel-icon: green;
          --header-primary: ${palette.fg0};
          --header-secondary: ${palette.fg2};
          --scrollbar-thin-track: transparent;
          --scrollbar-auto-track: transparent;
        }
      '';
  };
}
