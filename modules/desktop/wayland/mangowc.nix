{
  flake.nixos.wayland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib) types getExe getExe';
      cfg = config.me.desktop;
    in
    {
      options.me.desktop.monitors = lib.mkOption {
        type = types.attrsOf (types.listOf types.str);
        description = "monitor name -> list of tag names";
        example = lib.literalExpression ''
          { "DP-1" = [ "1" "2" "3" ]; }
        '';
      };

      config = {
        hj.xdg.config.files."zsh/.zshrc".text =
          lib.mkBefore # bash
            ''
              [[ $(tty) == "/dev/tty1" ]] && {
                export XDG_SESSION_TYPE=wayland
                export XDG_CURRENT_DESKTOP=mango
                exec mango
              }
            '';

        programs.xwayland.enable = true;

        systemd.user.targets.mango-session = {
          description = "Mango compositor session";
          bindsTo = [ "graphical-session.target" ];
          wants = [ "graphical-session-pre.target" ];
          after = [ "graphical-session-pre.target" ];
        };

        packages = with pkgs; [
          wl-clipboard
          unstable.mangowc
        ];

        xdg.portal = {
          extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
          ];

          config.mango = {
            default = [ "gtk" ];

            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.ScreenShot" = [ "wlr" ];
            "org.freedesktop.impl.portal.Inhibit" = [ ];
          };
        };

        tinted.files.".config/mango/config.conf" =
          let
            mkMangoBind =
              name: cfg:
              let
                parts = lib.splitString "+" name;
                key = lib.last parts;
                modStr = lib.concatStringsSep "+" (
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
                bindStr = if modStr == "" then "NONE,${key}" else "${modStr},${key}";
              in
              "${bindStr},spawn,${cfg.cmd}";

            assignRules = lib.map (cfg: "tags:${cfg.workspace},appid:${cfg.name}") config.me.desktop.assign;

            floatingRules = lib.map (
              cfg: "isfloating:${if cfg.enable then "1" else "0"},${cfg.type}:${cfg.name}"
            ) config.me.desktop.floating;

            mkMangoKeyValue =
              k: v:
              if builtins.isList v then
                lib.concatMapStringsSep "\n" (item: "${k}=${item}") v
              else
                "${k}=${toString v}";
          in
          {
            stripHash = true;
            generator = lib.generators.toKeyValue { mkKeyValue = mkMangoKeyValue; };
            value =
              p:
              {
                repeat_rate = 30;
                repeat_delay = 200;
                xkb_rules_layout = "us";
                xkb_rules_options = "compose:menu";
                sloppyfocus = 1;
                warpcursor = 1;
                focus_on_activate = 1;
                trackpad_natural_scrolling = 1;
                disable_while_typing = 1;
                drag_tile_to_tile = 1;
                tap_to_click = 1;
                tap_and_drag = 1;
                cursor_size = 24;

                exchange_cross_monitor = 1;
                focus_cross_monitor = 1;

                borderpx = 0;
                gappih = 0;
                gappiv = 0;
                gappoh = 0;
                gappov = 0;
                border_radius = 0;
                bordercolor = "0x${p.bg0}aa";
                focuscolor = "0x${p.fg2}ff";
                rootcolor = "0x${p.bg0}ff";

                blur = 0;
                shadows = 0;
                animations = 0;

                new_is_master = 1;
                default_mfact = "0.50";
                default_nmaster = 1;

                circle_layout = "tile,monocle";
                no_border_when_single = 1;

                windowrule = [
                  "tags:3,appid:${config.me.desktop.browser}"
                  "ignore_maximize:1,appid:${config.me.desktop.browser}"
                  "isfloating:1,title:About"
                  "isfloating:1,title:Organizer"
                  "isfloating:1,title:Preferences"
                  "isfloating:1,appid:Main|Matplotlib"
                ]
                ++ assignRules
                ++ floatingRules;

                exec = [
                  "${getExe pkgs.swaybg} -c \"#${p.bg0}\""
                  "${getExe pkgs.bash} -c '${getExe pkgs.my.swap-theme} $(cat $HOME/.local/state/tinted/theme)'"
                ]
                ++ map (_: _.cmd) (lib.filter (c: c.always) (lib.attrValues config.me.desktop.startup));

                "exec-once" = [
                  "${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP LIBVA_DRIVER_NAME GBM_BACKEND __GLX_VENDOR_LIBRARY_NAME"
                  "${getExe' pkgs.systemd "systemctl"} --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP"
                  "${getExe' pkgs.systemd "systemctl"} --user start mango-session.target"
                ]
                ++ map (_: _.cmd) (lib.filter (c: !c.always) (lib.attrValues config.me.desktop.startup));

                bind = [
                  "SUPER+SHIFT,r,reload_config"
                  "SUPER,q,killclient"
                  "SUPER,f,togglefullscreen"
                  "SUPER,Return,togglefloating"
                  "SUPER,g,toggleoverview"
                  "SUPER,c,centerwin"
                  "SUPER,i,spawn,${getExe' pkgs.procps "pkill"} -USR1 waybar"
                  "SUPER,a,switch_layout"

                  "SUPER,j,focusstack,prev"
                  "SUPER,k,focusstack,next"

                  "SUPER,h,focusdir,left"
                  "SUPER,l,focusdir,right"

                  "SUPER+CTRL,j,exchange_stack_client,down"
                  "SUPER+CTRL,k,exchange_stack_client,up"
                  "SUPER+CTRL,h,exchange_client,left"
                  "SUPER+CTRL,l,exchange_client,right"

                  "SUPER+SHIFT,h,resizewin,-30,0"
                  "SUPER+SHIFT,j,resizewin,0,30"
                  "SUPER+SHIFT,k,resizewin,0,-30"
                  "SUPER+SHIFT,l,resizewin,30,0"
                ]
                ++ (lib.mapAttrsToList mkMangoBind config.me.desktop.bindings)
                ++ (lib.flatten (
                  (lib.mapAttrsToList (
                    monitor: tags: map (tag: "SUPER,${tag},viewcrossmon,${tag},${monitor}") tags
                  ) cfg.monitors)
                  ++ (lib.mapAttrsToList (
                    monitor: tags: map (tag: "SUPER+SHIFT,${tag},tagcrossmon,${tag},${monitor}") tags
                  ) cfg.monitors)
                ));

                mousebind = [
                  "SUPER,btn_left,moveresize,curmove"
                  "SUPER,btn_right,moveresize,curresize"
                ];
              }
              // {
                tagrule = lib.flatten (
                  lib.mapAttrsToList (
                    monitor: tags: map (tag: "id:${tag},monitor_name:${monitor},no_hide:1,layout_name:monocle") tags
                  ) cfg.monitors
                );
              };
          };
      };
    };
}
