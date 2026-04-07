{
  flake.nixos.wayland =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (lib) getExe getExe';
    in
    {
      hj.xdg.config.files."zsh/.zshrc".text =
        lib.mkBefore # bash
          ''
            [[ $(tty) == "/dev/tty1" ]] && {
              exec mango > /dev/null 2>&1 
            }
          '';

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
          prefix = false;
          generator = lib.generators.toKeyValue { mkKeyValue = mkMangoKeyValue; };
          value = p: {
            env = [
              "DISPLAY,:0"
              "XDG_CURRENT_DESKTOP,mango"
            ];

            repeat_rate = 30;
            repeat_delay = 200;
            xkb_rules_layout = "us";
            sloppyfocus = 1;
            warpcursor = 1;
            focus_on_activate = 1;
            trackpad_natural_scrolling = 1;
            disable_while_typing = 1;
            tap_to_click = 1;
            tap_and_drag = 1;
            cursor_size = 24;

            borderpx = 1;
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
            smartgaps = 1;

            tagrule = map (id: "id:${toString id},layout_name:tile") (lib.range 1 9);

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
              "${getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP"
              "${getExe' pkgs.systemd "systemctl"} --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP"
              "${getExe' pkgs.systemd "systemctl"} --user start graphical-session.target"
              "${getExe pkgs.kanshi}"
            ]
            ++ map (_: _.cmd) (lib.filter (c: !c.always) (lib.attrValues config.me.desktop.startup));

            bind = [
              "SUPER,r,reload_config"
              "SUPER+SHIFT,r,reload_config"
              "SUPER,q,killclient"
              "SUPER,f,togglefullscreen"
              "SUPER,Return,togglefloating"
              "SUPER,c,centerwin"
              "SUPER,i,spawn,${getExe' pkgs.procps "pkill"} -USR1 waybar"
              "SUPER,a,spawn_shell,[ \"$(mmsg -e | ...)\" = tile ] && mmsg dispatch setlayout monocle || mmsg dispatch setlayout tile"
              "SUPER,j,focusdir,down"
              "SUPER,k,focusdir,up"
              "SUPER,h,focusdir,left"
              "SUPER,l,focusdir,right"
              "SUPER+CTRL,h,exchange_client,left"
              "SUPER+CTRL,j,exchange_client,down"
              "SUPER+CTRL,k,exchange_client,up"
              "SUPER+CTRL,l,exchange_client,right"
              "SUPER+SHIFT,h,resizewin,-30,0"
              "SUPER+SHIFT,j,resizewin,0,30"
              "SUPER+SHIFT,k,resizewin,0,-30"
              "SUPER+SHIFT,l,resizewin,30,0"
            ]
            ++ map (n: "SUPER,${toString n},view,${toString n}") (lib.range 1 9)
            ++ [ "SUPER,0,view,10" ]
            ++ map (n: "SUPER+SHIFT,${toString n},tag,${toString n}") (lib.range 1 9)
            ++ [ "SUPER+SHIFT,0,tag,10" ]
            ++ (lib.mapAttrsToList mkMangoBind config.me.desktop.bindings);

            mousebind = [
              "SUPER,btn_left,moveresize,curmove"
              "SUPER,btn_right,moveresize,curresize"
            ];
          };
        };
    };
}
