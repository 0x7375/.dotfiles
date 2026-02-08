{
  lib,
  config,
  mkBundle,
  ...
}:
let
  cfg = config.tinted;
  home = config.me.home;
  tintedDir = ".local/state/tinted";

  applyIfFn = f: arg: if lib.isFunction f then f arg else f;

  palette =
    theme: prefix:
    let
      base = if prefix then "palette" else "hex";
    in
    config.me.${base}.${theme};

  mkThemeFile =
    fileCfg: themePalette:
    if fileCfg.generator != null then
      {
        value = if fileCfg.value != null then applyIfFn fileCfg.value themePalette else themePalette;
        inherit (fileCfg) generator;
      }
    else if fileCfg.source != null then
      {
        source = applyIfFn fileCfg.source themePalette;
      }
    else if fileCfg.text != null then
      {
        text = applyIfFn fileCfg.text themePalette;
      }
    else
      throw "must specify one of text, source, or generator";

  mkTintedFile =
    targetPath: fileCfg:
    let
      sourcePath = "${tintedDir}/${targetPath}";
      dirParts = lib.splitString "/" targetPath;
      dir = lib.concatStringsSep "/" (lib.init dirParts);
      sourceDir = lib.concatStringsSep "/" (lib.init (lib.splitString "/" sourcePath));

      absTarget = "${home}/${targetPath}";
      absSource = "${home}/${sourcePath}-${cfg.defaultTheme}";
      absDirs = [
        "${home}/${dir}"
        "${home}/${sourceDir}"
      ];
    in
    {
      files =
        lib.mapAttrs'
          (
            theme: _:
            lib.nameValuePair "${sourcePath}-${theme}" (mkThemeFile fileCfg (palette theme fileCfg.prefix))
          )
          {
            dark = null;
            light = null;
          };

      activation = {
        dirs = absDirs;
        link = {
          source = absSource;
          target = absTarget;
        };
      };
    };

  processed = lib.mapAttrs mkTintedFile cfg.files;
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
      in
      lib.mkOption {
        type = types.attrsOf (
          types.submodule {
            options = {
              text = lib.mkOption {
                type = types.nullOr (types.functionTo (types.either types.str types.lines));
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
        example = {
          ".Xresources" = {
            text = palette: ''
              *bg0: ${palette.bg0}
            '';
          };
        };
      };
  };

  config = lib.mkIf cfg.enable (mkBundle {
    hj.files = lib.mergeAttrsList (lib.attrValues (lib.mapAttrs (_: v: v.files) processed));

    nixos.systemd.user.tmpfiles.rules = lib.concatMap (
      v:
      (map (d: "d ${d} 0755 ${config.me.user} users - -") v.activation.dirs)
      ++ [ "L ${v.activation.link.target} - - - - ${v.activation.link.source}" ]
    ) (lib.attrValues processed);

    darwin.activation = ''
      ${lib.concatMapStringsSep "\n" (v: ''
        ${lib.concatMapStringsSep "\n" (d: "mkdir -p ${d}") v.activation.dirs}
        ln -sf ${v.activation.link.source} ${v.activation.link.target}
        chown -h ${config.me.user} ${v.activation.link.target}
      '') (lib.attrValues processed)}
    '';
  });
}
