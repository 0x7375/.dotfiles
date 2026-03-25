{
  flake.nixos.wayland =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) getExe getExe';

      mkHyprBind =
        name: cfg:
        let
          parts = lib.splitString "+" name;
          key = lib.last parts;
          modStr = lib.concatStringsSep " " (
            map (
              m:
              if m == "Mod" then
                "SUPER"
              else if m == "Alt" then
                "ALT"
              else
                lib.toUpper m
            ) (lib.init parts)
          );

          prefix = if cfg.release then "bindr" else "bind";
          bindStr = if modStr == "" then ", ${key}" else "${modStr}, ${key}";
        in
        "${prefix} = ${bindStr}, exec, ${cfg.cmd}";

      mkHyprStart =
        _: cfg:
        let
          prefix = if cfg.always then "exec" else "exec-once";
        in
        "${prefix} = ${cfg.cmd}";

      extraBinds = lib.concatStringsSep "\n" (lib.mapAttrsToList mkHyprBind config.me.desktop.bindings);
      startupCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList mkHyprStart config.me.desktop.startup);

      assignRules = lib.concatMapStringsSep "\n" (
        cfg: "windowrulev2 = workspace ${cfg.workspace}, ${cfg.type}:^(${cfg.name})$"
      ) config.me.desktop.assign;

      floatingRules = lib.concatMapStringsSep "\n" (
        cfg: "windowrulev2 = ${if cfg.enable then "float" else "tile"}, ${cfg.type}:^(${cfg.name})$"
      ) config.me.desktop.floating;
    in
    {
      hj.xdg.config.files."zsh/.zshrc".text =
        lib.mkBefore # bash
          ''
            [[ $(tty) == "/dev/tty1" ]] && {
              if uwsm check may-start; then
                  exec uwsm start hyprland-uwsm.desktop > /dev/null 2>&1 
              fi
            }
          '';

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      tinted.files.".config/hypr/hyprland.conf" = {
        prefix = false;
        text =
          p:
          # hyprlang
          ''
            env = DISPLAY,:0
            env = XDG_CURRENT_DESKTOP,Hyprland

            monitor = , preferred, auto, ${toString config.me.desktop.scaling}

            general {
              gaps_in = 0
              gaps_out = 0
              border_size = 1
              col.active_border = rgba(${p.fg2}ff)
              col.inactive_border = rgba(${p.bg0}aa)
              layout = dwindle
              no_focus_fallback = true
            }

            group {
              col.border_active = rgba(${p.fg2}ff)
              col.border_inactive = rgba(${p.bg0_dark}aa)

              groupbar {
                render_titles = false
                height = 2
                indicator_height = 2
                indicator_gap = 0
                gaps_in = 0
                gaps_out = 0
                rounding = 0
                col.active = rgba(${p.fg2}ff)
                col.inactive = rgba(${p.bg0_dark}ff)
              }
            }

            decoration {
              rounding = 0
              blur {
                enabled = false
              }
              shadow {
                enabled = false
              }
            }

            animations {
              enabled = false
            }

            bind = , swipe:3:d, fullscreen, 0
            bind = , swipe:3:u, fullscreen, 0

            misc {
              disable_hyprland_logo = true
              disable_splash_rendering = true
              focus_on_activate = true
              new_window_takes_over_fullscreen = 2
              middle_click_paste = false
              mouse_move_enables_dpms = true
              key_press_enables_dpms = true
            }

            input {
              kb_options = compose:menu
              repeat_rate = 30
              repeat_delay = 200
              follow_mouse = 2
              float_switch_override_focus = 0
              touchpad {
                natural_scroll = true
              }
            }

            cursor {
              hide_on_key_press = true
            }

            binds {
              movefocus_cycles_fullscreen = false
            }

            ecosystem {
              no_update_news = true
            }

            dwindle {
              preserve_split = true
              force_split = 2
            }

            ${assignRules}
            ${floatingRules}

            windowrulev2 = workspace 3, class:^(${config.me.desktop.browser})$

            windowrulev2 = float, title:^(About)$
            windowrulev2 = float, title:^(Organizer)$
            windowrulev2 = float, title:^(Preferences)$
            windowrulev2 = float, class:^(Main|Matplotlib)$

            windowrulev2 = noscreenshare,class:^(Bitwarden)$
            windowrulev2 = suppressevent maximize, class:^(${config.me.desktop.browser})$
            windowrulev2 = center, floating:1

            windowrulev2 = noblur, class:^(Gromit-mpx)$
            windowrulev2 = opacity 1 override 1 override, class:^(Gromit-mpx)$
            windowrulev2 = noshadow, class:^(Gromit-mpx)$
            windowrulev2 = suppressevent fullscreen, class:^(Gromit-mpx)$
            windowrulev2 = size 100% 100%, class:^(Gromit-mpx)$

            workspace = w[t1], gapsout:0, gapsin:0
            workspace = w[tg1], gapsout:0, gapsin:0
            workspace = f[1], gapsout:0, gapsin:0

            workspace = special:gromit, gapsin:0, gapsout:0, on-created-empty:${getExe pkgs.gromit-mpx} -a

            windowrulev2 = bordersize 0, floating:0, onworkspace:w[t1]
            windowrulev2 = rounding 0, floating:0, onworkspace:w[t1]
            windowrulev2 = bordersize 0, floating:0, onworkspace:w[tg1]
            windowrulev2 = rounding 0, floating:0, onworkspace:w[tg1]
            windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
            windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

            ${startupCmds}
            ${extraBinds}

            bind = SUPER, i, exec, ${getExe' pkgs.procps "pkill"} -USR1 waybar

            bind = SUPER, o, togglespecialworkspace, gromit
            bind = , F9, togglespecialworkspace, gromit

            bind = SUPER, q, killactive
            bind = SUPER, f, fullscreen, 0
            bind = SUPER, Return, togglefloating
            bind = SUPER SHIFT, r, exec, hyprctl reload

            bind = SUPER, a, togglegroup

            bind = SUPER, c, centerwindow


            bind = SUPER, j, movefocus, d
            bind = SUPER, k, movefocus, u
            bind = SUPER, h, exec, if [ $(hyprctl activewindow -j | jq "(.grouped|length==0) or (.address==.grouped[0])") = "true" ]; then hyprctl dispatch movefocus l; else hyprctl dispatch changegroupactive b; fi
            bind = SUPER, l, exec, if [ $(hyprctl activewindow -j | jq "(.grouped|length==0) or (.address==.grouped[-1])") = "true" ]; then hyprctl dispatch movefocus r; else hyprctl dispatch changegroupactive f; fi

            bind = SUPER CTRL, h, movewindoworgroup, l
            bind = SUPER CTRL, j, movewindoworgroup, d
            bind = SUPER CTRL, k, movewindoworgroup, u
            bind = SUPER CTRL, l, movewindoworgroup, r

            bind = SUPER CTRL, BackSpace, movewindow, l
            bind = SUPER CTRL, Tab, movewindow, d
            bind = SUPER CTRL SHIFT, Tab, movewindow, u

            bind = SUPER SHIFT, h, resizeactive, -30 0
            bind = SUPER SHIFT, j, resizeactive, 0 30
            bind = SUPER SHIFT, k, resizeactive, 0 -30
            bind = SUPER SHIFT, l, resizeactive, 30 0

            bind = SUPER, 1, workspace, 1
            bind = SUPER, 2, workspace, 2
            bind = SUPER, 3, workspace, 3
            bind = SUPER, 4, workspace, 4
            bind = SUPER, 5, workspace, 5
            bind = SUPER, 6, workspace, 6
            bind = SUPER, 7, workspace, 7
            bind = SUPER, 8, workspace, 8
            bind = SUPER, 9, workspace, 9
            bind = SUPER, 0, workspace, 10

            bind = SUPER SHIFT, 1, movetoworkspace, 1
            bind = SUPER SHIFT, 2, movetoworkspace, 2
            bind = SUPER SHIFT, 3, movetoworkspace, 3
            bind = SUPER SHIFT, 4, movetoworkspace, 4
            bind = SUPER SHIFT, 5, movetoworkspace, 5
            bind = SUPER SHIFT, 6, movetoworkspace, 6
            bind = SUPER SHIFT, 7, movetoworkspace, 7
            bind = SUPER SHIFT, 8, movetoworkspace, 8
            bind = SUPER SHIFT, 9, movetoworkspace, 9
            bind = SUPER SHIFT, 0, movetoworkspace, 10

            bindm = SUPER, mouse:272, movewindow
            bindm = SUPER, mouse:273, resizewindow

            exec = ${getExe pkgs.swaybg} -c "${p.bg0}"
            exec = "${getExe pkgs.bash} -c '${getExe pkgs.my.swap-theme} $(cat $HOME/.local/state/tinted/theme)'";
            exec-once = ${getExe' pkgs.hyprland "hyprctl"} dispatch workspace 1
            exec-once = ${getExe pkgs.kanshi}

            exec-once = ${
              getExe (
                pkgs.writeShellApplication {
                  name = "auto-group";
                  runtimeInputs = with pkgs; [
                    socat
                    jq
                  ];
                  text = builtins.readFile ./merge.sh;
                }
              )
            } &

            source = ~/.config/hypr/workspaces.conf
          '';
      };

      hj.xdg.config.files."hypr/hyprpaper.conf".text = ''
        ipc = true
      '';
    };
}
