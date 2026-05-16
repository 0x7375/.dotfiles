{
  flake.modules.generic.custom =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.tinted;
      palette = theme: stripHash: if stripHash then cfg.hex.${theme} else cfg.colors.${theme};

      mkThemeFile =
        fileCfg: themePalette:
        let
          base =
            if fileCfg.generator != null then
              {
                value = if fileCfg.value != null then fileCfg.value themePalette else themePalette;
                inherit (fileCfg) generator;
              }
            else if fileCfg.source != null then
              { source = fileCfg.source themePalette; }
            else if fileCfg.text != null then
              { text = fileCfg.text themePalette; }
            else
              throw "must specify one of text, source, or generator";
        in
        base // lib.optionalAttrs fileCfg.executable { executable = true; };
    in
    {
      options.tinted = {
        enable = lib.mkEnableOption "themed configuration management";

        palette = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
          default = { };
          description = "Per-color palette entries. Values should include the # symbol.";
        };

        _themes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          internal = true;
          default = lib.unique (lib.concatMap lib.attrNames (lib.attrValues cfg.palette));
        };

        colors = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
          internal = true;
          default = lib.genAttrs cfg._themes (theme: lib.mapAttrs (_: v: v.${theme}) cfg.palette);
        };

        hex = lib.mkOption {
          type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
          internal = true;
          default = lib.mapAttrs (_: lib.mapAttrs (_: lib.removePrefix "#")) cfg.colors;
        };

        user = lib.mkOption {
          type = lib.types.str;
        };

        homeDir = lib.mkOption {
          type = lib.types.str;
          default = "/home/${config.tinted.user}";
        };

        stateDir = lib.mkOption {
          type = lib.types.str;
          default = ".local/state/tinted";
        };

        defaultTheme = lib.mkOption {
          type = lib.types.str;
          default = builtins.head cfg._themes;
        };

        files =
          let
            inherit (lib) types;

            mergeable =
              {
                name,
                check,
                merge,
              }:
              types.mkOptionType {
                inherit name;
                description = "palette -> ${name}, or plain ${name}";
                check = v: lib.isFunction v || check v;
                merge =
                  _loc: defs:
                  let
                    fns = map (d: if lib.isFunction d.value then d.value else _: d.value) defs;
                  in
                  palette: merge (map (f: f palette) fns);
              };
          in
          lib.mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  executable = lib.mkEnableOption "";
                  text = lib.mkOption {
                    type = types.nullOr (mergeable {
                      name = "string";
                      check = lib.isString;
                      merge = lib.concatStrings;
                    });
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
                    type = types.nullOr (mergeable {
                      name = "attrs";
                      check = lib.isAttrs;
                      merge =
                        let
                          deepMerge =
                            a: b:
                            if lib.isAttrs a && lib.isAttrs b then
                              lib.zipAttrsWith (_: v: builtins.foldl' deepMerge (builtins.head v) (builtins.tail v)) [
                                a
                                b
                              ]
                            else if lib.isList a && lib.isList b then
                              a ++ b
                            else
                              b;
                        in
                        builtins.foldl' deepMerge { };
                    });
                    default = null;
                  };
                  stripHash = lib.mkOption {
                    type = types.bool;
                    default = false;
                  };
                };
              }
            );
            default = { };
            example = lib.literalExpression ''
              {
                ".Xresources".text = palette: '''
                  *bg0: ''${palette.red}
                  *red: ''${palette.red}
                ''';
              }
            '';
          };

        _activations = lib.mkOption {
          type = lib.types.attrsOf lib.types.attrs;
          internal = true;
          default = lib.mapAttrs (targetPath: _: {
            dirs = [
              (builtins.dirOf "${cfg.homeDir}/${targetPath}")
              (builtins.dirOf "${cfg.homeDir}/${cfg.stateDir}/${targetPath}")
            ];
            source = "${cfg.homeDir}/${cfg.stateDir}/${targetPath}-${cfg.defaultTheme}";
            target = "${cfg.homeDir}/${targetPath}";
          }) cfg.files;
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [
          {
            assertion = cfg.palette != { };
            message = "tinted: palette is empty";
          }
        ];

        hj.files = lib.concatMapAttrs (
          targetPath: fileCfg:
          lib.mergeAttrsList (
            map (theme: {
              "${cfg.stateDir}/${targetPath}-${theme}" = mkThemeFile fileCfg (palette theme fileCfg.stripHash);
            }) cfg._themes
          )
        ) cfg.files;
      };
    };

  flake.modules.nixos.custom =
    { config, lib, ... }:
    {
      systemd.user.tmpfiles.rules = lib.concatMap (
        v:
        map (d: "d ${d} 0755 ${config.me.user} users - -") v.dirs ++ [ "L ${v.target} - - - - ${v.source}" ]
      ) (lib.attrValues config.tinted._activations);
    };

  flake.modules.darwin.custom =
    { config, lib, ... }:
    {
      activation = lib.concatMapStringsSep "\n" (v: ''
          ${lib.concatMapStringsSep "\n" (d: "mkdir -p ${d}") v.dirs}
        ln -s ${v.source} ${v.target} 2> /dev/null || true
        chown -h ${config.me.user} ${v.target}
      '') (lib.attrValues config.tinted._activations);
    };
}
