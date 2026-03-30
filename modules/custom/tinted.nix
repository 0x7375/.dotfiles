{
  flake.shared.custom =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.tinted;
      inherit (config.me) home;
      tintedDir = ".local/state/tinted";
      themes = [
        "dark"
        "light"
      ];

      applyIfFn = f: arg: if lib.isFunction f then f arg else f;
      dirname = path: lib.concatStringsSep "/" (lib.init (lib.splitString "/" path));
      palette = theme: prefix: config.me.${if prefix then "palette" else "hex"}.${theme};

      mkThemeFile =
        fileCfg: themePalette:
        if fileCfg.generator != null then
          {
            value = if fileCfg.value != null then applyIfFn fileCfg.value themePalette else themePalette;
            inherit (fileCfg) generator;
          }
        else if fileCfg.source != null then
          { source = applyIfFn fileCfg.source themePalette; }
        else if fileCfg.text != null then
          { text = fileCfg.text themePalette; }
        else
          throw "must specify one of text, source, or generator";
    in
    {
      options.tinted = {
        enable = lib.mkEnableOption "themed configuration management";
        defaultTheme = lib.mkOption {
          type = lib.types.enum [
            "dark"
            "light"
          ];
          default = "dark";
        };
        files =
          let
            inherit (lib) types;
            paletteTextType = lib.types.mkOptionType {
              name = "paletteText";
              description = "palette -> string, or plain string";
              check = v: lib.isFunction v || lib.isString v;
              merge =
                _loc: defs:
                let
                  fns = map (d: if lib.isFunction d.value then d.value else _: d.value) defs;
                in
                palette: lib.concatMapStrings (f: f palette) fns;
            };
          in
          lib.mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  text = lib.mkOption {
                    type = lib.types.nullOr paletteTextType;
                    default = null;
                  };
                  source = lib.mkOption {
                    type = types.nullOr (types.functionTo types.path);
                    default = null;
                  };
                  generator = lib.mkOption {
                    type = types.nullOr (types.functionTo (types.either types.str types.path));
                    default = null;
                  };
                  value = lib.mkOption {
                    type = types.nullOr (types.functionTo types.attrs);
                    default = null;
                  };
                  prefix = lib.mkOption {
                    type = types.bool;
                    default = true;
                  };
                };
              }
            );
            default = { };
            example.".Xresources".text = ''
              *bg0: ''${palette.red}
              *red: ''${palette.red}
            '';
          };
        _activations = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          internal = true;
          default = lib.mapAttrs (targetPath: _: {
            dirs = [
              "${home}/${dirname targetPath}"
              "${home}/${dirname "${tintedDir}/${targetPath}"}"
            ];
            source = "${home}/${tintedDir}/${targetPath}-${cfg.defaultTheme}";
            target = "${home}/${targetPath}";
          }) cfg.files;
        };
      };

      config = lib.mkIf cfg.enable {
        hj.files = lib.concatMapAttrs (
          targetPath: fileCfg:
          lib.listToAttrs (
            map (
              theme:
              lib.nameValuePair "${tintedDir}/${targetPath}-${theme}" (
                mkThemeFile fileCfg (palette theme fileCfg.prefix)
              )
            ) themes
          )
        ) cfg.files;
      };
    };

  flake.nixos.custom =
    { config, lib, ... }:
    {
      systemd.user.tmpfiles.rules = lib.concatMap (
        v:
        map (d: "d ${d} 0755 ${config.me.user} users - -") v.dirs ++ [ "L ${v.target} - - - - ${v.source}" ]
      ) (lib.attrValues config.tinted._activations);
    };

  flake.darwin.custom =
    { config, lib, ... }:
    {
      activation = lib.concatMapStringsSep "\n" (v: ''
          ${lib.concatMapStringsSep "\n" (d: "mkdir -p ${d}") v.dirs}
        ln -s ${v.source} ${v.target} 2> /dev/null || true
        chown -h ${config.me.user} ${v.target}
      '') (lib.attrValues config.tinted._activations);
    };
}
