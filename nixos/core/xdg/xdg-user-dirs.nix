{ lib, ... }:

let
  directories = {
    XDG_DESKTOP_DIR = "$HOME";
    XDG_DOCUMENTS_DIR = "$HOME/documents";
    XDG_DOWNLOAD_DIR = "$HOME/downloads";
    XDG_MUSIC_DIR = "$HOME";
    XDG_PICTURES_DIR = "$HOME/pictures";
    XDG_PUBLICSHARE_DIR = "$HOME";
    XDG_SCREENSHOTS_DIR = "$HOME/pictures/screenshots/linux";
    XDG_TEMPLATES_DIR = "$HOME";
    XDG_VIDEOS_DIR = "$HOME/pictures/videos";
  };
  # For some reason, these need to be wrapped with quotes to be valid.
  wrapped = lib.mapAttrs (_: value: ''"${value}"'') directories;
in
{
  hj.xdg.config.files."user-dirs.conf".text = "enabled=False";
  hj.xdg.config.files."user-dirs.dirs".text = lib.generators.toKeyValue { } wrapped;

  vars = directories;

  system.activationScripts.createXdgUserDirectories =
    let
      directoriesList = lib.attrValues directories;
      mkdir = (dir: ''[[ -L "${dir}" ]] || mkdir -p $VERBOSE_ARG "${dir}"'');
    in
    lib.strings.concatMapStringsSep "\n" mkdir directoriesList;
}
