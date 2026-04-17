{
  flake.nixos.custom =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.me.desktop;

      monitorScript = pkgs.writeShellScriptBin "mango-monitor-setup" ''
        case "$1" in
          ${lib.concatStringsSep "\n  " (
            lib.mapAttrsToList (
              name: _:
              "${name}) ln -sf \"$HOME/.config/mango/profiles/${name}.conf\" \"$HOME/.config/mango/monitors.conf\" ;;"
            ) cfg.monitors
          )}
        esac
        mmsg -d reload_config
        ${lib.getExe pkgs.my.waybar-output}
      '';
    in
    {
      options.me.desktop = {
        monitorScript = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          default = monitorScript;
        };
        monitors = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf (lib.types.listOf lib.types.str));
          default = { };
        };
      };

      config = lib.mkIf (cfg.monitors != { }) {
        tinted.files.".config/mango/config.conf".value.source = [ "~/.config/mango/monitors.conf" ];

        hj.files = lib.mapAttrs' (
          name: monitorMap:
          lib.nameValuePair ".config/mango/profiles/${name}.conf" {
            text = lib.concatStrings (
              lib.flatten (
                lib.mapAttrsToList (
                  monitor: tags:
                  [ "monitorrule = name:${monitor},scale:${toString cfg.scaling}\n" ]
                  ++ map (tag: ''
                    bind = SUPER,${tag},viewcrossmon,${tag},${monitor}
                    bind = SUPER+SHIFT,${tag},tagcrossmon,${tag},${monitor}
                    bind = SUPER+CTRL,${tag},comboview,${tag},${monitor}
                    tagrule = id:${tag},monitor_name:${monitor},no_hide:1,layout_name:monocle
                  '') tags
                ) monitorMap
              )
            );
          }
        ) cfg.monitors;
      };
    };
}
