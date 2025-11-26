{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.me.wm.enable {
  packages = with pkgs; [
    libnotify
    dunst
  ];

  hj.xdg.data.files."dbus-1/services/org.knopwob.dunst.service".source =
    "${pkgs.dunst}/share/dbus-1/services/org.knopwob.dunst.service";

  systemd.user.services.dunst = {
    description = "Dunst notification daemon";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    # reloadTriggers = [ "${config.hj.files.".config/dunst/dunstrc".source}" ];

    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = lib.escapeShellArgs [
        (lib.getExe pkgs.dunst)
      ];
      ExecReload = "${pkgs.dunst}/bin/dunstctl reload";
    };
  };

  tinted.files.".config/dunst/dunstrc" = {
    generator = (
      lib.generators.toINI {
        mkKeyValue =
          key: value:
          let
            value' =
              if lib.isBool value then
                (if value then "yes" else "no")
              else if lib.isString value then
                ''"${value}"''
              else
                toString value;
          in
          "${key}=${value'}";
      }
    );
    value = palette: rec {
      global = {
        background = palette.bg0;
        foreground = palette.fg0;
        highlight = palette.fg0;
        frame_color = palette.bg1;

        icon_path = "${config.me.flakeDir}/.assets/dunst/output/${palette._theme}";
        monitor = 0;
        follow = "none";
        width = 400;
        height = 200;
        origin = "top-center";
        offset = "0x${
          toString (
            if config.me.wm.displayServer == "xorg" then
              config.me.barHeight + 10
            else
              config.programs.waybar.settings.primary.height
          )
        }";
        scale = 0;
        notification_limit = 20;

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_frame_width = 0;
        progress_bar_min_width = 400;
        progress_bar_max_width = 400;
        progress_bar_corner_radius = 0;

        default_icon = "bell";
        icon_corner_radius = 0;
        indicate_hidden = true;
        transparency = 0;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 24;
        text_icon_padding = 24;
        frame_width = 3;
        gap_size = 0;
        separator_color = "frame";
        sort = true;
        font = "Cartograph CF 14";
        line_height = 6;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = false;
        icon_position = "left";
        min_icon_size = 80;
        max_icon_size = 80;
        sticky_history = true;
        history_length = 20;
        browser = "${lib.getExe' pkgs.xdg-utils "xdg-open"}";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        corner_radius = 0;
        ignore_dbusclose = false;
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "do_action";
        mouse_right_click = "close_current";
      };
      urgency_low = urgency_normal;
      urgency_normal = {
        timeout = 3;
      };
      urgency_critical = {
        frame_color = palette.red;
        foreground = palette.red;
        timeout = 0;
      };
      # z_ is necessary to force the rule to be at the end of the file
      z_experimental = {
        per_monitor_dpi = false;
      };
      z_charging = {
        appname = "charging";
        history_ignore = true;
      };
      z_charged = {
        appname = "charged";
        frame_color = palette.green;
        foreground = palette.green;
      };
      z_sleep = {
        appname = "sleep";
        frame_color = palette.sleep;
        foreground = palette.sleep;
        timeout = 0;
      };
      volume = {
        appname = "volume";
        history_ignore = true;
      };
    };
  };
}
