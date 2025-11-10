{
  lib,
  config,
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
      # // {
      #   "${targetPath}" = {
      #     type = "symlink";
      #     clobber = false;
      #     source = "${home}/${sourcePath}-${cfg.defaultTheme}";
      # };
      # };

      tmpfiles = [
        "d ${home}/${dir} 0755 ${config.me.user} users - -"
        "d ${home}/${sourceDir} 0755 ${config.me.user} users - -"
        "L ${home}/${targetPath} - - - - ${home}/${sourcePath}-${cfg.defaultTheme}" # when using smfh linker
      ];
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
              *fg0: ${palette.fg0}
              *red: ${palette.red}
              *green: ${palette.green}
              *yellow: ${palette.yellow}
              *blue: ${palette.blue}
              *magenta: ${palette.magenta}
              *cyan: ${palette.cyan}
            '';
          };
        };
      };
  };

  config = lib.mkIf cfg.enable {
    hj.files = lib.mergeAttrsList (lib.attrValues (lib.mapAttrs (_: v: v.files) processed));
    systemd.user.tmpfiles.rules = lib.concatLists (
      lib.attrValues (lib.mapAttrs (_: v: v.tmpfiles) processed)
    );
  };
}
