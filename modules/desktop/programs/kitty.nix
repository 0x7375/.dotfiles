{
  flake.modules.nixos.kitty =
    { pkgs, ... }:
    {
      xdg.terminal-exec.settings.default = [ "kitty.desktop" ];
      environment.systemPackages = [ pkgs.kitty ];
    };

  flake.modules.darwin.kitty = {
    homebrew.casks = [ "kitty" ];
  };

  flake.modules.generic.kitty =
    { config, ... }:
    {
      nixpkgs.overlays = [
        (final: _: {
          inherit (final.unstable) kitty;
        })
      ];

      me.desktop.terminal = {
        name = "kitty";
        cmd = "kitty -1";
      };

      xdg.desktopEntries.kitty = {
        name = "kitty";
        exec = "kitty -1";
        icon = "kitty";
        terminal = false;
        type = "Application";
      };

      tinted.files.".config/kitty/kitty.conf" = {
        stripHash = true;
        text = p: ''
          font_family ${config.me.desktop.terminal.font.family}
          font_size ${toString config.me.desktop.terminal.font.size}

          allow_remote_control yes

          disable_ligatures always

          window_padding_width 20
          hide_window_decorations yes

          enable_audio_bell no
          cursor_shape block
          cursor_blink_interval 0

          cursor none
          confirm_os_window_close 0

          foreground #${p.fg0}
          background #${p.bg0}

          color0 #${p.bg1}
          color1 #${p.red}
          color2 #${p.green}
          color3 #${p.yellow}
          color4 #${p.blue}
          color5 #${p.magenta}
          color6 #${p.cyan}
          color7 #${p.fg4} # fg color of lf error message

          color8 #${p.gray} # command completion
          color9 #${p.red}
          color10 #${p.green}
          color11 #${p.yellow}
          color12 #${p.blue}
          color13 #${p.magenta}
          color14 #${p.cyan}
          color15 #${p.fg0}

          map alt+v paste_from_clipboard
          map alt+c copy_to_clipboard
          map alt+shift+u change_font_size all +2.0
          map alt+shift+d change_font_size all -2.0
          map alt+shift+r change_font_size all 0
          mouse_map middle release ungrabbed,grabbed
        '';
      };
    };
}
